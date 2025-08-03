# Home Orbit

A simple webserver framework for making small home webservers intended only for personal use

## Running

All you need is Rust and Cargo to run: `cargo run`

## Structure

Under the hood this framework is using the `axum` crate to manage basic webserver protocol.
The project structure is the following:
```
route/
    ... # all the url paths you need
scripts/
    html.lua # lua html interfacing 
    http.lua # lua http interfacing
    ... # your personal libraries
src/
    main.rs # with the home-orbit crate
start.lua # setup webserver with i.e. state
Cargo.toml # the usual rust executable with home-orbit as a dependency
```

### Routing

The file structure in this folder represents the webservers internal routing.
These Lua files will be read and run on any request, there is no caching.
The code is very straight forward when using the previously mentioned integrated libraries:
```lua
---@param attrs table<string, string>
---@return string
return function(attrs, ...)
    -- potentially more code
    return htmlDocument {
        head {
            -- styling and so on
        };
        body {
            -- actual html content
        };
    }
end
```

### State

To share state it uses axums state implementation and the internal `AppState` structure, where the Lua state is saved.
```rust
pub struct AppState {
    lua: Arc<Lua>
}
```
That means you can use globals to share state between the handles.

## Service

Before the program starts, the following things are done:
1. Create a new Lua runtime
2. Execute `start.lua`
3. Load all lua files under `scripts/`
4. Axum service is started

This is how requests are processed:
1. Request arrived and the rust `handle` function is called
2. Route file is loaded and returning function captured
3. `handle.lua` is run if it exists
4. Route handle function is called
5. HTTP response is constructed from the returning table