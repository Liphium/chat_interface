use std::collections::HashMap;

use lazy_static::lazy_static;
use tokio::sync::Mutex;

use crate::{
    frb_generated::StreamSink,
    lightwire::{self, Engine},
};

lazy_static! {
    // Bindings for the lightwire engine
    static ref ENGINE_COUNT: Mutex<u32> = Mutex::new(0);
    static ref ENGINE_MAP: Mutex<HashMap<u32, Option<Engine>>> = Mutex::new(HashMap::new());

    // Bindings for the logging from Rust
    static ref LOG_SINK: Mutex<Option<StreamSink<String>>> = Mutex::new(None);
}

// Create a new engine in global state (needed for the binding to Dart)
pub async fn create_engine() -> u32 {
    // Calculate the next index and increment the count
    let index = {
        let mut count = ENGINE_COUNT.lock().await;
        *count += 1;
        count.clone()
    };

    // Add an empty engine to the map
    let mut map = ENGINE_MAP.lock().await;
    map.insert(index, None);

    return index;
}

// Initialize an engine with the callback sending back the packets
pub async fn init_engine<F>(id: u32, mut send_fn: F)
where
    F: FnMut((Vec<u8>, bool)) + Send + 'static,
{
    // Get the global map of engines
    let mut map = ENGINE_MAP.lock().await;
    map.insert(
        id,
        Some(
            lightwire::Engine::create(move |packet| {
                send_fn((packet.encode(), packet.speech.unwrap_or(false)));
            })
            .await,
        ),
    );
}

// Get an engine from the map
pub async fn get_engine(id: u32) -> Option<Engine> {
    let map = ENGINE_MAP.lock().await;
    let result = map.get(&id);
    if result.is_none() {
        return None;
    }

    return result.unwrap().to_owned();
}

// Set the sink of the log stream
pub async fn set_log_sink(sink: StreamSink<String>) {
    let mut stream = LOG_SINK.lock().await;
    *stream = Some(sink);
}

// Log information
pub fn info_impl(message: &str) {
    let sink = LOG_SINK.blocking_lock();
    if let Some(sink) = sink.as_ref() {
        sink.add(format!("info: {}", message))
            .expect("Couldn't send log message");
    } else {
        println!("info: {}", message);
    }
}

// Log an error
pub fn error_impl(message: &str) {
    let sink = LOG_SINK.blocking_lock();
    if let Some(sink) = sink.as_ref() {
        sink.add(format!("error: {}", message))
            .expect("Couldn't send log message");
    } else {
        println!("error: {}", message);
    }
}

#[macro_export]
macro_rules! info {
    ($($arg:tt)*) => {
        $crate::binding::info_impl(&format!($($arg)*))
    };
}

#[macro_export]
macro_rules! error {
    ($($arg:tt)*) => {
        $crate::binding::error_impl(&format!($($arg)*))
    };
}
