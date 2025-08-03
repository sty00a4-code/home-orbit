use axum::body::boxed;
use axum::{
    Router,
    body::Body,
    extract::{OriginalUri, Query, State},
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::get,
};
use mlua::{FromLuaMulti, Function, Lua, Table, Value};
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

pub async fn run_app() -> Result<(), mlua::Error> {
    let lua = Lua::new();
    lua.load(&fs::read_to_string("start.lua")?)
        .set_name("start.lua")
        .exec()?;
    let state = AppState {
        lua: Arc::new(Mutex::new(lua)),
    };
    let app = Router::new().route("/*path", get(handle)).with_state(state);
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
    Ok(())
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

    // Load helper scripts
    if let Err(err) = require_folder(&mut lua, "scripts") {
        return err;
    }

    // Load the route handler
    let route_file = format!("route{}.lua", original_uri.path());
    let handler: Function = match require(&mut lua, &route_file) {
        Ok(f) => f,
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
