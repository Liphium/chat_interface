use std::{thread, time::Duration};

use libspaceship::api;

fn main() {
    let devices = api::list_input_devices();
    for device in devices {
        println!("Device: {:?}", device.id);
    }
}

pub fn test_voice() {
    api::test_voice();
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
