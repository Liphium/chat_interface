use std::sync::Mutex;

use once_cell::sync::Lazy;


use crate::util;

pub mod udp;
pub mod receiver;

pub struct Config {
    pub test: bool,
    pub client_id: String,
    pub verification_key: Vec<u8>,
    pub encryption_key: Vec<u8>,
    pub connection: bool
}

// If the app should stop
static STOP_CHAT: Lazy<Mutex<bool>> = Lazy::new(|| Mutex::new(false));

pub fn allow_start() {
    *STOP_CHAT.lock().unwrap() = false;
}

pub fn should_stop() -> bool {
    *STOP_CHAT.lock().unwrap()
}

pub fn stop() {
    *STOP_CHAT.lock().unwrap() = true;
}

pub fn get_key(token: &str) -> Vec<u8> {
    util::hasher::sha256(token.as_bytes().to_vec())
}

pub fn construct_packet(config: &Config, voice_data: &[u8], buffer: &mut Vec<u8>) {
    buffer.clear();
    buffer.extend_from_slice(config.client_id.as_bytes());

    // Build verification thing
    let hash = util::hasher::sha256(voice_data.to_vec());
    let verifier = util::crypto::encrypt(&config.verification_key, &hash);
    buffer.push(b':');
    buffer.extend_from_slice(&verifier);

    // Encrypt voice data
    let encrypted = util::crypto::encrypt(&config.encryption_key, voice_data);
    buffer.extend_from_slice(&encrypted);
}