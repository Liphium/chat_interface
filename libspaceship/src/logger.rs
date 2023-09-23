use std::{sync::Mutex, time::{SystemTime, UNIX_EPOCH}};

use flutter_rust_bridge::StreamSink;
use once_cell::sync::Lazy;

use crate::api;

// Tags
pub static TAG_COMMUNICATION: &str = "communication";
pub static TAG_AUDIO: &str = "audio";
pub static TAG_CONNECTION: &str = "connection";
pub static TAG_CODEC: &str = "codec";
pub static TAG_ERROR: &str = "error";

static STREAM_SINK: Lazy<Mutex<Option<StreamSink<api::LogEntry>>>> = Lazy::new(|| Mutex::new(None));

pub fn set_stream_sink(s: StreamSink<api::LogEntry>) {
    let mut sink = STREAM_SINK.lock().unwrap();
    *sink = Some(s);
    drop(sink);
}

pub fn send_log(tag: &str, msg: &str) {
    let mut sink = STREAM_SINK.lock().unwrap();
    match *sink {
        Some(ref mut s) => {
            s.add(api::LogEntry {
                time_secs: SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs() as i64,
                tag: tag.into(),
                msg: msg.into(),
            });
        },
        None => {},
    }
}