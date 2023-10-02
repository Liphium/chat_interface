use base64::{engine::general_purpose, Engine};
use serde::{Deserialize, Serialize};
use serde_json::Value;

use crate::{util, audio};

#[derive(Deserialize, Serialize)]
struct Event {
    name: String,
    sender: String,
    data: Value
}

pub fn receive_packet(config: &super::Config, data: &Vec<u8>) -> Result<(), String> {

    let decrypted = util::crypto::decrypt_sodium(&config.encryption_key, data);
    let event: Event = match serde_json::from_str(String::from_utf8_lossy(decrypted.as_slice()).as_ref()) {
        Ok(event) => event,
        Err(_) => return Err("Could not parse event".to_string())
    };

    if event.name == "voice" && event.data.is_object() {

        let val = event.data.as_object().expect("Invalid voice packet");

        // Decode voice packet
        let decoded = general_purpose::STANDARD.decode(String::from(val["data"].as_str().unwrap())).expect("Invalid voice packet");
        audio::decode::pass_to_decode(decoded);
    }

    return Ok(())
}