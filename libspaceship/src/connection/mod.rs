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

#[derive(Clone, PartialEq)]
pub enum Protocol {
    Hz48000, // Currently supported and tested
    Hz24000, // Not supported
    Hz16000, // Well, it works, but it's shit
    Hz12000, // Not supported
    Hz8000, // Not supported
    None
}

impl Protocol {
    pub fn opus_sample_rate(&self) -> audiopus::SampleRate {
        match &self {
            Self::Hz48000 => audiopus::SampleRate::Hz48000,
            Self::Hz24000 => audiopus::SampleRate::Hz24000,
            Self::Hz16000 => audiopus::SampleRate::Hz16000,
            Self::Hz12000 => audiopus::SampleRate::Hz12000,
            Self::Hz8000 => audiopus::SampleRate::Hz8000, 
            Self::None => audiopus::SampleRate::Hz48000,
        }
    }

    pub fn usize(&self) -> usize {
        match &self {
            Self::Hz48000 => 48000,
            Self::Hz24000 => 24000,
            Self::Hz16000 => 16000,
            Self::Hz12000 => 12000,
            Self::Hz8000 => 8000, 
            Self::None => 48000,
        }
    }

    pub fn packet_prefix(&self) -> &str {
        match &self {
            Self::Hz48000 => "o4",
            Self::Hz24000 => "o3",
            Self::Hz16000 => "o2",
            Self::Hz12000 => "o1",
            Self::Hz8000 => "o0", 
            Self::None => "n-"
        }
    }
}

pub fn nearest_opus_protocol(sample_size: u32) -> Protocol {
    if sample_size >= 40000 {
        Protocol::Hz48000
    } else if sample_size >= 20000 {
        Protocol::Hz24000
    } else if sample_size >= 14000 {
        Protocol::Hz16000
    } else if sample_size >= 10000 {
        Protocol::Hz12000
    } else {
        Protocol::Hz8000
    }
}

// If the app should stop
static STOP_CHAT: Lazy<Mutex<bool>> = Lazy::new(|| Mutex::new(false));
static MIC_PROTOCOL: Lazy<Mutex<Protocol>> = Lazy::new(|| Mutex::new(Protocol::None));

pub fn allow_start() {
    *STOP_CHAT.lock().unwrap() = false;
}

pub fn should_stop() -> bool {
    *STOP_CHAT.lock().unwrap()
}

pub fn new_protocol(p: Protocol) {
    *MIC_PROTOCOL.lock().unwrap() = p
}

pub fn get_protocol() -> Protocol {
    match MIC_PROTOCOL.lock() {
        Ok(thing) => thing.clone(),
        Err(thing) => thing.into_inner().clone(),
    }
}

pub fn protocol_from_prefix(prefix: &str) -> Option<Protocol> {
    match prefix {
        "o4" => Some(Protocol::Hz48000),
        "o3" => Some(Protocol::Hz24000),
        "o2" => Some(Protocol::Hz16000),
        "o1" => Some(Protocol::Hz12000),
        "o0" => Some(Protocol::Hz8000), 
        "n-" => Some(Protocol::None),
        _ => None
    }
}

pub fn stop() {
    *STOP_CHAT.lock().unwrap() = true;
}

pub fn get_key(token: &str) -> Vec<u8> {
    util::hasher::sha256(token.as_bytes().to_vec())
}

pub fn construct_packet(config: &Config, protocol: &Protocol, voice_data: &[u8], buffer: &mut Vec<u8>) {
    buffer.clear();
    buffer.extend_from_slice(config.client_id.as_bytes());

    // Build verification thing
    let mut voice_vec = protocol.packet_prefix().as_bytes().to_vec();
    voice_vec.extend_from_slice(voice_data);
    let encrypted_voice = util::crypto::encrypt_sodium(&config.encryption_key, &voice_vec);
    let hash = util::hasher::sha256(encrypted_voice.to_vec());
    let encrypted_verifier = util::crypto::encrypt(&config.verification_key, &hash);
    let encoded_verifier = general_purpose::STANDARD_NO_PAD.encode(&encrypted_verifier);
    buffer.extend_from_slice(&encoded_verifier.as_bytes());
    buffer.push(b':');

    // Encrypt voice data
    buffer.extend_from_slice(&encrypted_voice);
}