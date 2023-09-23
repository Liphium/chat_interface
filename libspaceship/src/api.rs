use std::sync::Arc;

use flutter_rust_bridge::StreamSink;

use crate::{connection, logger, audio::{encode, decode}};

pub struct LogEntry {
    pub time_secs: i64,
    pub tag: String,
    pub msg: String,
}

pub fn create_log_stream(s: StreamSink<LogEntry>) {
    logger::set_stream_sink(s);
}

pub fn send_log(s: String) {
    logger::send_log("test", s.as_str());
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

    encode::encode_thread(config.clone(), 1);
    decode::decode_play_thread();
}