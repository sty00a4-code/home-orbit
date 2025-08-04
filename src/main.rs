#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let _ = dbg!(home_orbit_lib::run_app().await);
    Ok(())
}