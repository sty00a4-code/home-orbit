#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    home_orbit_lib::run_app().await.unwrap();
    Ok(())
}