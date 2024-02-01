use std::{
    sync::Mutex,
    time::{SystemTime, UNIX_EPOCH},
};

use once_cell::sync::Lazy;

use crate::{api, frb_generated::StreamSink};

// Tags
pub static TAG_COMMUNICATION: &str = "communication";
pub static TAG_AUDIO: &str = "audio";
pub static TAG_CONNECTION: &str = "connection";
pub static TAG_ERROR: &str = "error";

static LOG_STDOUT: Lazy<Mutex<bool>> = Lazy::new(|| Mutex::new(false));
static STREAM_SINK: Lazy<Mutex<Option<StreamSink<api::interaction::LogEntry>>>> =
    Lazy::new(|| Mutex::new(None));

pub fn set_stream_sink(s: StreamSink<api::interaction::LogEntry>) {
    let mut sink = STREAM_SINK.lock().unwrap();
    *sink = Some(s);
    drop(sink);
}

pub fn send_log(tag: &str, msg: &str) {
    if *LOG_STDOUT.lock().unwrap() {
        println!("{}: {}", tag, msg);
    }

    let mut sink = STREAM_SINK.lock().unwrap();
    match *sink {
        Some(ref mut s) => {
            s.add(api::interaction::LogEntry {
                time_secs: SystemTime::now()
                    .duration_since(UNIX_EPOCH)
                    .unwrap()
                    .as_secs() as i64,
                tag: tag.into(),
                msg: msg.into(),
            });
        }
        None => {}
    }
}

pub fn set_log_stdout(b: bool) {
    let mut stdout = LOG_STDOUT.lock().unwrap();
    *stdout = b;
    drop(stdout);
}
