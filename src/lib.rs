use axum::body::boxed;
use axum::response::Redirect;
use axum::{
    Router,
    body::Body,
    extract::{OriginalUri, Query, State},
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::get,
};
use mlua::{FromLuaMulti, Function, IntoLua, Lua, Table, Value};
use std::{
    collections::HashMap,
    fs,
    net::SocketAddr,
    sync::{Arc, Mutex},
};

#[derive(Debug, Clone)]
pub struct AppState {
    lua: Arc<Mutex<Lua>>,
}
unsafe impl Send for AppState {}
unsafe impl Sync for AppState {}

pub fn get_css(_: &Lua, (name,): (String,)) -> Result<String, mlua::Error> {
    fs::read_to_string(format!("styles/{name}.css"))
        .map_err(|err| mlua::Error::RuntimeError(err.to_string()))
}
pub fn get_styles(lua: &Lua, _: ()) -> Result<Value, mlua::Error> {
    fs::read_dir("styles")?
        .flatten()
        .zip(fs::read_dir("styles")?.flatten().filter_map(|file| {
            file.file_name()
                .into_string()
                .unwrap_or_default()
                .split_once(".")
                .map(|(name, _)| name.to_string())
        }))
        .filter_map(|(file, name)| {
            file.path()
                .to_str()
                .and_then(|path| fs::read_to_string(format!("{path}")).ok())
                .map(|content| (name, content))
        })
        .collect::<HashMap<String, String>>()
        .into_lua(lua)
}
pub fn get_script(_: &Lua, (name,): (String,)) -> Result<String, mlua::Error> {
    fs::read_to_string(format!("scripts/{name}.js"))
        .map_err(|err| mlua::Error::RuntimeError(err.to_string()))
}
pub fn get_scripts(lua: &Lua, _: ()) -> Result<Value, mlua::Error> {
    fs::read_dir("scripts")?
        .flatten()
        .zip(fs::read_dir("scripts")?.flatten().filter_map(|file| {
            file.file_name()
                .into_string()
                .unwrap_or_default()
                .split_once(".")
                .map(|(name, _)| name.to_string())
        }))
        .filter_map(|(file, name)| {
            file.path()
                .to_str()
                .and_then(|path| fs::read_to_string(format!("{path}")).ok())
                .map(|content| (name, content))
        })
        .collect::<HashMap<String, String>>()
        .into_lua(lua)
}

pub async fn run_app() -> Result<(), mlua::Error> {
    let mut lua = Lua::new();
    // custom functions
    {
        let f = lua.create_function(get_css)?;
        lua.globals().set("getCSS", f)?;
        let f = lua.create_function(get_styles)?;
        lua.globals().set("getStyles", f)?;
        let f = lua.create_function(get_script)?;
        lua.globals().set("getScript", f)?;
        let f = lua.create_function(get_scripts)?;
        lua.globals().set("getScripts", f)?;
    }
    // execute start.lua
    lua.load(&fs::read_to_string("start.lua")?)
        .set_name("start.lua")
        .exec()?;
    // load libs
    if let Err(err) = require_folder(&mut lua, "libs") {
        return Err(mlua::Error::RuntimeError(format!("{err:?}")));
    }
    // create app
    let state = AppState {
        lua: Arc::new(Mutex::new(lua)),
    };
    let app = Router::new()
        .route("/", get(|| async { Redirect::permanent("/home") }))
        .route("/*path", get(handle))
        .with_state(state);
    // serve app
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    println!("{addr}");
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .map_err(|err| mlua::Error::RuntimeError(format!("{err:?}")))
}

pub fn require<T: FromLuaMulti>(lua: &mut Lua, path: &str) -> Result<T, Response> {
    match fs::read_to_string(path) {
        Ok(code) => match lua.load(&code).set_name(path).eval::<T>() {
            Ok(v) => Ok(v),
            Err(e) => return Err(format!("[ERROR] loading '{path}': {e}").into_response()),
        },
        Err(e) => return Err(format!("[ERROR] reading '{path}': {e}").into_response()),
    }
}
pub fn require_folder(lua: &mut Lua, path: &str) -> Result<(), Response> {
    let files =
        fs::read_dir(path).map_err(|e| format!("[ERROR] reading 'path': {e}").into_response())?;
    for file in files.flatten() {
        let Ok(typ) = file.file_type() else {
            continue;
        };
        if typ.is_file() {
            let file_path = file.path();
            let Some(path) = file_path.to_str() else {
                continue;
            };
            require::<Value>(lua, path)?;
        }
    }
    Ok(())
}

pub async fn handle(
    State(state): State<AppState>,
    OriginalUri(original_uri): OriginalUri,
    Query(query): Query<HashMap<String, String>>,
) -> Response {
    // Clone the Lua VM handle
    let mut lua = state.lua.lock().unwrap();

    // Load the route handler
    let route_file = format!("route{}.lua", original_uri.path());
    let handler: Function = match require(&mut lua, &route_file) {
        Ok(f) => f,
        Err(resp) => return resp,
    };

    match require::<Function>(&mut lua, "handle.lua") {
        Ok(f) => match f.call::<Value>(query.clone()) {
            Ok(_) => {}
            Err(e) => {
                let msg = format!("[ERROR] calling '{}': {}", "handle.lua", e);
                return (StatusCode::INTERNAL_SERVER_ERROR, msg).into_response();
            }
        },
        Err(resp) => return resp,
    };
    // Call the Lua handler (it returns a table)
    match handler.call::<Table>(query) {
        Ok(tbl) => {
            let status = tbl.get::<u16>("status").unwrap_or(200);
            let body = tbl
                .get::<Option<String>>("body")
                .unwrap_or(None)
                .unwrap_or_default();

            let mut builder = Response::builder().status(status);
            if let Ok(Some(hdrs)) = tbl.get::<Option<Table>>("headers") {
                for pair in hdrs.pairs::<String, String>().flatten() {
                    builder = builder.header(pair.0, pair.1);
                }
            }
            builder.body(boxed(Body::from(body))).unwrap()
        }
        Err(e) => {
            let msg = format!("[ERROR] calling '{}': {}", route_file, e);
            (StatusCode::INTERNAL_SERVER_ERROR, msg).into_response()
        }
    }
}
