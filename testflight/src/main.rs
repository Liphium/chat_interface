use rust_lib::{api, communication};

fn main() {
    api::interaction::test_voice("def".to_string());
    communication::start_listening();
}
