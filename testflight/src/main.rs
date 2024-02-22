use rust_lib::{api, communication};

fn main() {
    api::interaction::test_voice("def".to_string());
    communication::start_listening();

    /*

    // Listen for stdout
    let mut buffer = String::new();
    std::io::stdin().read_line(&mut buffer).unwrap();

    // Parse like a3ztEsimy2:BTK2/9sh8oqc34uynQjPTGGNriIvgooF65L6Nq6s/v4=
    let mut split = buffer.split(':');
    let client_id = split.nth(0).unwrap();
    let verification_key = split.nth(0).unwrap();
    println!("client_id: {}", client_id);
    println!("verification_key: {}", verification_key);

    connection::udp::connect_recursive(
        client_id.trim().to_string(),
        verification_key.trim().to_string(),
        "sKgXUYWo5bpnTb8HxGK06AVyJRg3UEvjlUGj1LPCBmU=".to_string(),
        "localhost:3011",
        0,
        true,
    )*/
}
