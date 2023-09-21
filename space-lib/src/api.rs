use flutter_rust_bridge::StreamSink;

use crate::{connection, logger};

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