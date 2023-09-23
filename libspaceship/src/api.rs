use std::sync::Arc;

use flutter_rust_bridge::StreamSink;

use crate::{connection, logger, audio::{decode, microphone, self, AUDIO_OPTIONS}, util};

//* App logic */

pub struct LogEntry {
    pub time_secs: i64,
    pub tag: String,
    pub msg: String,
}

pub fn create_log_stream(s: StreamSink<LogEntry>) {
    logger::set_stream_sink(s);
}

pub fn create_action_stream(s: StreamSink<String>) {
    util::set_action_sink(s);
}

pub fn start_voice(client_id: String, verification_key: String, encryption_key: String, address: String) {
    connection::udp::init();
    connection::udp::connect_recursive(client_id, verification_key, encryption_key, address.as_str(), 0, false)
}

pub fn test_voice() {
    let config = Arc::new(connection::Config {
        test: true,
        client_id: "test".to_string(),
        verification_key: vec![0; 32],
        encryption_key: vec![0; 32],
        connection: false,
    });

    decode::decode_play_thread();
    microphone::record(config.clone());
}

pub fn stop() {
    connection::stop();
}

//* Audio crab */

pub fn set_muted(muted: bool) {
    let mut options = AUDIO_OPTIONS.lock().unwrap();
    (*options).muted = muted;
}

pub fn set_deafen(deafened: bool) {
    let mut options = AUDIO_OPTIONS.lock().unwrap();
    (*options).deafened = deafened;
}

pub fn is_muted() -> bool {
    let options = AUDIO_OPTIONS.lock().unwrap();
    options.muted
}

pub fn is_deafened() -> bool {
    let options = AUDIO_OPTIONS.lock().unwrap();
    options.deafened
}

pub fn set_amplitude_logging(amplitude_logging: bool) {
    let mut options = AUDIO_OPTIONS.lock().unwrap();
    (*options).amplitude_logging = amplitude_logging;
}

pub fn is_amplitude_logging() -> bool {
    let options = AUDIO_OPTIONS.lock().unwrap();
    options.amplitude_logging
}

pub fn set_talking_amplitude(amplitude: f32) {
    let mut options = AUDIO_OPTIONS.lock().unwrap();
    (*options).talking_amplitude = amplitude;
}

pub fn get_talking_amplitude() -> f32 {
    let options = AUDIO_OPTIONS.lock().unwrap();
    options.talking_amplitude
}

pub fn set_silent_mute(silent_mute: bool) {
    let mut options = AUDIO_OPTIONS.lock().unwrap();
    (*options).silent_mute = silent_mute;
}

pub fn create_amplitude_stream(s: StreamSink<f32>) {
    audio::encode::set_amplitude_sink(s);
}

pub fn delete_amplitude_stream() {
    audio::encode::delete_sink();
}
