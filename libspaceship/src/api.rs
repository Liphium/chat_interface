use std::sync::Arc;

use flutter_rust_bridge::StreamSink;

use crate::{connection, logger, audio::{decode, microphone}, util};

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