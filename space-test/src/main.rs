use std::{thread, time::Duration};

use libspaceship::{api, connection};


fn main() {
    connect_to_space_node();
}

pub fn connect_to_local_server() {
    libspaceship::logger::set_log_stdout(true);
    libspaceship::api::set_talking_amplitude(0.0f32);
    connection::udp::init();
    connection::udp::connect_read("localhost:3011")
}

pub fn connect_to_space_node() {
    libspaceship::logger::set_log_stdout(true);
    libspaceship::api::set_talking_amplitude(0.0f32);
    connection::udp::init();
    connection::udp::connect_read("128.140.35.38:4101")
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
