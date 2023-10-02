use std::{thread, time::Duration, io};

use alkali::{symmetric::auth::Key, mem::FullAccess};
use base64::{engine::general_purpose, Engine};
use libspaceship::{api, connection};

static KEY: &str = "6HDUlw4Gyeu8pVpSD54YHW6gJ7fJilD5MR63MNiFdJI=";

fn main() {
    
    let key = parse_sodium_key(KEY.to_string());
    println!("Key: {:?}", key);
}

pub fn parse_sodium_key(to_parse: String) -> Key<FullAccess> {
    let mut key = Key::<FullAccess>::new_empty().unwrap();
    let bytes = general_purpose::STANDARD.decode(to_parse.as_bytes()).unwrap();
    key.copy_from_slice(&bytes);
    key
}

pub fn connect_to_server() {
    let devices = api::list_input_devices();
    for device in devices {
        println!("Device: {:?}", device.id);
    }
    libspaceship::logger::set_log_stdout(true);
    connection::udp::init();
    connection::udp::connect_read("localhost:3011")
}

pub fn test_voice() {
    api::test_voice(api::get_default_id());
    let mut tries = 0;
    loop {
        tries += 1;
        if tries >= 3 {
            break;
        }
        thread::sleep(Duration::from_secs(1));
    }
    api::stop();
    thread::sleep(Duration::from_secs(10));
}
