use cpal::traits::{DeviceTrait, HostTrait};

use crate::{
    audio::{self, microphone},
    frb_generated::StreamSink,
    logger, util,
};

//* App logic */
pub struct LogEntry {
    pub time_secs: i64,
    pub tag: String,
    pub msg: String,
}

pub fn create_log_stream(s: StreamSink<LogEntry>) {
    logger::set_stream_sink(s);
    logger::send_log(logger::TAG_COMMUNICATION, "THIS IS A TEST MESSAGE")
}

pub struct Action {
    pub action: String,
    pub data: String,
}

pub fn create_action_stream(s: StreamSink<Action>) {
    util::set_action_sink(s);
}

pub fn start_talking_engine() {
    audio::set_amplitude_logging(false);
    microphone::allow_start();
    microphone::record();
}

pub fn test_voice(device: String, detection_mode: i32) {
    audio::set_amplitude_logging(true);
    audio::set_detection_mode(detection_mode);
    audio::set_input_device(device);
    microphone::allow_start();
    microphone::record();
}

pub fn stop() {
    microphone::stop();
}

//* Audio crab */
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

pub fn create_amplitude_stream(s: StreamSink<f32>) {
    audio::microphone::set_amplitude_sink(s);
}

pub fn delete_amplitude_stream() {
    audio::microphone::delete_sink();
    audio::set_amplitude_logging(false);
}

pub fn set_detection_mode(detection_mode: i32) {
    audio::set_detection_mode(detection_mode)
}

pub fn get_detection_mode() -> i32 {
    audio::get_detection_mode()
}

//* Device shit */
pub struct InputDevice {
    pub id: String,
    pub display_name: String,
    pub sample_rate: u32,
    pub best_quality: bool,
}

pub static DEFAULT_NAME: &str = "def";

// Get all input devices
pub fn list_input_devices() -> Vec<InputDevice> {
    let mut input_devices = Vec::new();
    let host = cpal::default_host();

    // On linux, use jack
    #[cfg(target_os = "linux")]
    {
        host = cpal::host_from_id(cpal::HostId::Jack).unwrap();
    }

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
        let display_name = id.clone();
        let input_device = InputDevice {
            id,
            display_name,
            sample_rate,
            best_quality: false,
        };
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

// Set devices
pub fn set_input_device(id: String) {
    audio::set_input_device(id)
}

pub fn set_output_device(id: String) {
    audio::set_output_device(id)
}
