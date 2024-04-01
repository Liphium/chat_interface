use std::{thread, time::Duration};

use rust_lib::{api, logger};

fn main() {
    logger::set_log_stdout(true);
    api::interaction::test_voice("def".to_string(), 0);

    loop {
        thread::sleep(Duration::from_millis(1000));
    }
}
