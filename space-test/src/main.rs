use std::{thread, time::Duration};

use libspaceship::api;

fn main() {
    api::test_voice();
    loop {
        thread::sleep(Duration::from_secs(1));
    }
}
