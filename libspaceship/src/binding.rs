use std::collections::HashMap;

use lazy_static::lazy_static;
use tokio::sync::Mutex;

use crate::lightwire::{self, Engine};

lazy_static! {
    static ref ENGINE_COUNT: Mutex<u32> = Mutex::new(0);
    static ref ENGINE_MAP: Mutex<HashMap<u32, Option<Engine>>> = Mutex::new(HashMap::new());
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
    F: FnMut(Vec<u8>) + Send + 'static,
{
    // Get the global map of engines
    let mut map = ENGINE_MAP.lock().await;
    map.insert(
        id,
        Some(
            lightwire::Engine::create(move |packet| {
                send_fn(packet.encode());
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
