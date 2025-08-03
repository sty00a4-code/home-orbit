use mlua::{Lua, Value, Error};

pub async fn call(src: &str) -> Result<Value, Error> {
    let lua = Lua::new();
    Ok(lua.load(src).eval_async().await?)
}