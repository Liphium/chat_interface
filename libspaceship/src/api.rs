use std::sync::Arc;

use alkali::symmetric::cipher;
use cpal::traits::HostTrait;
use flutter_rust_bridge::StreamSink;
use rodio::DeviceTrait;
use serde::de;

use crate::{connection, logger, audio::{microphone, self, AUDIO_OPTIONS}, util};

//* App logic */

pub struct LogEntry {
    pub time_secs: i64,
    pub tag: String,
    pub msg: String,
}

pub fn create_log_stream(s: StreamSink<LogEntry>) {
    logger::set_stream_sink(s);
}

pub struct Action {
    pub action: String,
    pub data: String,
}

pub fn create_action_stream(s: StreamSink<Action>) {
    util::set_action_sink(s);
}

pub fn start_voice(client_id: String, verification_key: String, encryption_key: String, address: String) {
    connection::allow_start();
    connection::udp::init();
    audio::set_amplitude_logging(false);
    connection::udp::connect_recursive(client_id, verification_key, encryption_key, address.as_str(), 0, false)
}

pub fn test_voice(device: String) {
    connection::allow_start();
    let config = Arc::new(connection::Config {
        test: true,
        client_id: "test".to_string(),
        verification_key: vec![0; 32],
        encryption_key: cipher::Key::generate().unwrap(),
        connection: false,
    });

    audio::set_amplitude_logging(true);
    audio::set_input_device(device);
    microphone::record(config.clone());
}

pub fn stop() {
    connection::stop();
}

//* Audio crab */

pub fn set_muted(muted: bool) {
    audio::set_muted(muted)
}

pub fn set_deafen(deafened: bool) {
    audio::set_deafen(deafened)
}

pub fn is_muted() -> bool {
    audio::is_muted()
}

pub fn is_deafened() -> bool {
    audio::is_deafened()
}

pub fn set_amplitude_logging(amplitude_logging: bool) {
    audio::set_amplitude_logging(amplitude_logging)
}

pub fn is_amplitude_logging() -> bool {
    audio::is_amplitude_logging()
}

pub fn set_talking_amplitude(amplitude: f32) {
    audio::set_talking_amplitude(amplitude)
}

pub fn get_talking_amplitude() -> f32 {
    audio::get_talking_amplitude()
}

pub fn set_silent_mute(silent_mute: bool) {
    audio::set_silent_mute(silent_mute)
}

pub fn create_amplitude_stream(s: StreamSink<f32>) {
    audio::encode::set_amplitude_sink(s);
}

pub fn delete_amplitude_stream() {
    audio::encode::delete_sink();
    audio::set_amplitude_logging(false);
}

//* Device shit */

pub struct InputDevice {
    pub id: String,
    pub sample_rate: u32,
    pub best_quality: bool,
}

pub static DEFAULT_NAME: &str = "def";

// Get all input devices
pub fn list_input_devices() -> Vec<InputDevice> {
    let mut input_devices = Vec::new();
    let host = cpal::default_host();
    let input_devices_iter = host.input_devices().unwrap();

    // Find microphones
    let mut best_sample_rate: u32 = 0;
    for device in input_devices_iter {
        let id = device.name().unwrap();
        let sample_rate = device.default_input_config().unwrap().sample_rate().0;
        if sample_rate > best_sample_rate {
            best_sample_rate = sample_rate;
        }

        // Add device
        let input_device = InputDevice { id, sample_rate, best_quality: false };
        input_devices.push(input_device);
    }

    // Assign the best ones the best quality
    for device in &mut input_devices {
        if device.sample_rate == best_sample_rate {
            device.best_quality = true;
        }
    }

    input_devices
}

// Get the id you have to pass in for the default device
pub fn get_default_id() -> String {
    DEFAULT_NAME.to_string()
}

pub struct OutputDevice {
    pub id: String,
}

// Get all output devices
pub fn list_output_devices() -> Vec<OutputDevice> {
    let mut output_devices = Vec::new();
    let host = cpal::default_host();
    let input_devices_iter = host.output_devices().unwrap();

    // Find microphones
    let _best_sample_rate: u32 = 0;
    for device in input_devices_iter {
        let id = device.name().unwrap();

        // Add device
        let input_device = OutputDevice { id };
        output_devices.push(input_device);
    }

    output_devices
}

// Set devices
pub fn set_input_device(id: String) {
    audio::set_input_device(id)
}

pub fn set_output_device(id: String) {
    audio::set_output_device(id)
}