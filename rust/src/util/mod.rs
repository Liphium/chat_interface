use std::sync::Mutex;

use once_cell::sync::Lazy;

use crate::{api, frb_generated::StreamSink, logger};

static ACTION_SINK: Lazy<Mutex<Option<StreamSink<api::interaction::Action>>>> =
    Lazy::new(|| Mutex::new(None));

pub fn set_action_sink(s: StreamSink<api::interaction::Action>) {
    let mut sink = ACTION_SINK.lock().unwrap();
    *sink = Some(s);
    drop(sink);
}

pub fn print_action(action: &str) {
    let mut sink = ACTION_SINK.lock().unwrap();
    match *sink {
        Some(ref mut s) => {
            s.add(api::interaction::Action {
                action: action.to_string(),
                data: "".to_string(),
            });
        }
        None => {}
    }
}

pub fn send_action(action: api::interaction::Action) {
    let mut sink = ACTION_SINK.lock().unwrap();
    match *sink {
        Some(ref mut s) => {
            s.add(action);
        }
        None => {}
    }
}


