use std::sync::Mutex;

use alkali::{symmetric::cipher, mem::FullAccess};
use base64::{engine::general_purpose, Engine};
use once_cell::sync::Lazy;


use crate::util;

pub mod udp;
pub mod receiver;

pub struct Config {
    pub test: bool,
    pub client_id: String,
    pub verification_key: Vec<u8>,
    pub encryption_key: cipher::Key<FullAccess>,
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
    let encrypted_voice = util::crypto::encrypt_sodium(&config.encryption_key, voice_data);
    let hash = util::hasher::sha256(encrypted_voice.to_vec());
    let encrypted_verifier = util::crypto::encrypt(&config.verification_key, &hash);
    let encoded_verifier = general_purpose::STANDARD_NO_PAD.encode(&encrypted_verifier);
    buffer.extend_from_slice(&encoded_verifier.as_bytes());
    buffer.push(b':');

    // Encrypt voice data
    buffer.extend_from_slice(&encrypted_voice);
}