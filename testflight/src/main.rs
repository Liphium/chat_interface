use rust_lib::{audio, connection};

fn main() {
    connection::allow_start();
    connection::udp::init();
    audio::set_amplitude_logging(true);

    // Listen for stdout
    let mut buffer = String::new();
    std::io::stdin().read_line(&mut buffer).unwrap();

    // Parse like a3ztEsimy2:BTK2/9sh8oqc34uynQjPTGGNriIvgooF65L6Nq6s/v4=
    let mut split = buffer.split(':');
    let client_id = split.nth(0).unwrap();
    let verification_key = split.nth(0).unwrap();
    println!("client_id: {}", client_id);
    println!("verification_key: {}", verification_key);

    let jitter_buffer_vec = [(&0, 1), (&0, 2), (&0, 3)];
    let last_seq = jitter_buffer_vec.into_iter().min_by(|x, y| (x.0).cmp(y.0));

    connection::udp::connect_recursive(
        client_id.trim().to_string(),
        verification_key.trim().to_string(),
        "sKgXUYWo5bpnTb8HxGK06AVyJRg3UEvjlUGj1LPCBmU=".to_string(),
        "localhost:3011",
        0,
        true,
    )
}
