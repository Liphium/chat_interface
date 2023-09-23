use std::sync::Mutex;

use flutter_rust_bridge::StreamSink;
use once_cell::sync::Lazy;
use rand::distributions::{Alphanumeric, DistString};

use crate::logger;

pub mod hasher;
pub mod crypto;

static ACTION_SINK: Lazy<Mutex<Option<StreamSink<String>>>> = Lazy::new(|| Mutex::new(None));

pub fn set_action_sink(s: StreamSink<String>) {
    let mut sink = ACTION_SINK.lock().unwrap();
    *sink = Some(s);
    drop(sink);
}

pub fn print_action(action: &str) {
    let mut sink = ACTION_SINK.lock().unwrap();
    match *sink {
        Some(ref mut s) => {
            s.add(action.to_string());
        },
        None => {},
    }
}

pub fn random_string(length: usize) -> String {
    return Alphanumeric.sample_string(&mut rand::thread_rng(), length);
}

#[deprecated(since="0.1.0", note="use logger module instead")]
pub fn print_log(message: &str) {
    logger::send_log("rust", message);
}