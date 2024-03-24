use rust_lib::{api, communication, logger};

fn main() {
    logger::set_log_stdout(true);
    api::interaction::test_voice("def".to_string(), 0);
    communication::start_listening();
}
