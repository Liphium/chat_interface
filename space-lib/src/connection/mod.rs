use std::sync::Mutex;

use once_cell::sync::Lazy;
use rand::{Rng, rngs::ThreadRng};

use crate::util;

pub mod udp;
pub mod receiver;

pub struct Config {
    pub client_id: String,
    pub verification_key: Vec<u8>,
    pub encryption_key: Vec<u8>,
    pub connection: bool
}

static CONN_ID: Lazy<Mutex<Vec<u8>>> = Lazy::new(|| {
    let mut rng = rand::thread_rng();
    Mutex::new(vec![random_letter_byte(&mut rng), random_letter_byte(&mut rng), random_letter_byte(&mut rng), random_letter_byte(&mut rng)])
});

fn random_letter_byte(rng: &mut ThreadRng) -> u8 {
    rng.sample(rand::distributions::Alphanumeric) as u8
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