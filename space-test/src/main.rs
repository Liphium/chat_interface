use std::{thread, time::Duration};

use libspaceship::{api, connection};


fn main() {
    connect_to_server();
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
