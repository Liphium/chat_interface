use std::collections::HashMap;

use lazy_static::lazy_static;
use libcgc::crypto::{asymmetric, signature, symmetric};
use tokio::sync::{Mutex, MutexGuard};

use crate::{
    frb_generated::StreamSink,
    lightwire::{self, Engine},
};

lazy_static! {
    // Bindings for the lightwire engine
    static ref ENGINE_COUNT: Mutex<u32> = Mutex::new(0);
    static ref ENGINE_MAP: Mutex<HashMap<u32, Option<Engine>>> = Mutex::new(HashMap::new());

    // Bindings for the encryption library
    static ref KEY_COUNT: Mutex<u32> = Mutex::new(0);
    static ref VERIFY_KEYS: Mutex<HashMap<u32, signature::VerifyingKey>> = Mutex::new(HashMap::new());
    static ref SIGN_KEYS: Mutex<HashMap<u32, signature::SigningKey>> = Mutex::new(HashMap::new());
    static ref PUBLIC_KEYS: Mutex<HashMap<u32, asymmetric::PublicKey>> = Mutex::new(HashMap::new());
    static ref SECRET_KEYS: Mutex<HashMap<u32, asymmetric::SecretKey>> = Mutex::new(HashMap::new());
    static ref SYMMETRIC_KEYS: Mutex<HashMap<u32, symmetric::SymmetricKey>> = Mutex::new(HashMap::new());

    // Bindings for the logging from Rust
    static ref LOG_SINK: std::sync::Mutex<Option<StreamSink<String>>> = std::sync::Mutex::new(None);
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
    F: FnMut((Option<Vec<u8>>, Option<f32>, Option<bool>)) + Send + 'static,
{
    // Get the global map of engines
    let mut map = ENGINE_MAP.lock().await;
    map.insert(
        id,
        Some(
            lightwire::Engine::create(move |packet| {
                send_fn((packet.encode(), packet.amplitude, packet.speech));
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

// Remove an engine from the map
pub async fn delete_engine(id: u32) {
    ENGINE_MAP.lock().await.remove(&id);
}

// Stop all engines
pub async fn stop_all_engines() {
    let mut map = ENGINE_MAP.lock().await;
    for (_, engine) in map.iter() {
        if let Some(engine) = engine {
            engine.stop().await;
        }
    }
    map.clear();
}

// Set the sink of the log stream
pub async fn set_log_sink(sink: StreamSink<String>) {
    let stream = LOG_SINK.lock().ok();
    if stream.is_none() {
        return;
    }
    *stream.unwrap() = Some(sink);
}

// Functions for storing the keys in the maps they belong to
pub async fn store_symmetric_key(key: symmetric::SymmetricKey) -> u32 {
    let index = next_key().await;
    let mut map = SYMMETRIC_KEYS.lock().await;
    map.insert(index, key);
    return index;
}
pub async fn symmetric_key_map() -> MutexGuard<'static, HashMap<u32, symmetric::SymmetricKey>> {
    SYMMETRIC_KEYS.lock().await
}

pub async fn store_verifying_key(key: signature::VerifyingKey) -> u32 {
    let index = next_key().await;
    let mut map = VERIFY_KEYS.lock().await;
    map.insert(index, key);
    return index;
}
pub async fn verifying_key_map() -> MutexGuard<'static, HashMap<u32, signature::VerifyingKey>> {
    VERIFY_KEYS.lock().await
}

pub async fn store_signing_key(key: signature::SigningKey) -> u32 {
    let index = next_key().await;
    let mut map = SIGN_KEYS.lock().await;
    map.insert(index, key);
    return index;
}
pub async fn signing_keys_map() -> MutexGuard<'static, HashMap<u32, signature::SigningKey>> {
    SIGN_KEYS.lock().await
}

pub async fn store_public_key(key: asymmetric::PublicKey) -> u32 {
    let index = next_key().await;
    let mut map = PUBLIC_KEYS.lock().await;
    map.insert(index, key);
    return index;
}
pub async fn public_key_map() -> MutexGuard<'static, HashMap<u32, asymmetric::PublicKey>> {
    PUBLIC_KEYS.lock().await
}

pub async fn store_secret_key(key: asymmetric::SecretKey) -> u32 {
    let index = next_key().await;
    let mut map = SECRET_KEYS.lock().await;
    map.insert(index, key);
    return index;
}
pub async fn secret_key_map() -> MutexGuard<'static, HashMap<u32, asymmetric::SecretKey>> {
    SECRET_KEYS.lock().await
}

async fn next_key() -> u32 {
    let mut count = KEY_COUNT.lock().await;
    *count += 1;
    count.clone()
}

// Log info
pub fn info<M: AsRef<str>>(message: M) {
    let sink = LOG_SINK.lock().unwrap();
    let msg = message.as_ref();
    if let Some(sink) = sink.as_ref() {
        sink.add(format!("info: {}", msg))
            .expect("Couldn't send log message");
    } else {
        println!("info: {}", msg);
    }
}

// Log an error
pub fn error<M: AsRef<str>>(message: M) {
    let sink = LOG_SINK.lock().unwrap();
    let msg = message.as_ref();
    if let Some(sink) = sink.as_ref() {
        sink.add(format!("error: {}", msg))
            .expect("Couldn't send log message");
    } else {
        println!("error: {}", msg);
    }
}
