use std::{process::Command, sync::Arc};

use alkali::symmetric::cipher;
use cpal::traits::HostTrait;
use rodio::DeviceTrait;

use crate::{
    audio::{self, microphone},
    connection,
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

pub fn start_voice(
    client_id: String,
    verification_key: String,
    encryption_key: String,
    address: String,
) {
    connection::allow_start();
    connection::udp::init();
    audio::set_amplitude_logging(false);
    connection::udp::connect_recursive(
        client_id,
        verification_key,
        encryption_key,
        address.as_str(),
        0,
        false,
    )
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
    pub display_name: String,
    pub sample_rate: u32,
    pub best_quality: bool,
}

struct PCMAndName {
    pub pcm_id: String,
    pub display_name: String,
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

    // Turn the pcm ids into actual microphones on linux
    #[cfg(target_os = "linux")]
    {
        // TODO: Fix this for linux

        // First, grab all the actually usable devices (and their name)
        let command = Command::new("arecord")
            .arg("-l")
            .output()
            .expect("couldn't run");
        let output = String::from_utf8_lossy(&command.stdout);
        println!("{}", output);
        let mut actual_devices = Vec::<String>::new();

        // Get list of actual devices
        for line in output.split("\n") {
            if line.starts_with("card") {
                let device_name = line
                    .trim()
                    .split(":")
                    .nth(1)
                    .unwrap()
                    .trim()
                    .split("[")
                    .nth(1)
                    .unwrap()
                    .trim()
                    .split("]")
                    .nth(0)
                    .unwrap()
                    .trim()
                    .to_string();
                actual_devices.insert(0, device_name);
            }
        }

        // Second, grab all the pcm ids and filter them based on the actual devices
        let command = Command::new("arecord")
            .arg("-L")
            .output()
            .expect("couldn't run");
        let output = String::from_utf8_lossy(&command.stdout);
        let mut working_pcms = Vec::<PCMAndName>::new();

        let mut pcm_id = "";
        for line in output.split("\n") {
            if line.starts_with(" ") && pcm_id != "" {
                let device_name = line.trim().to_string();

                // Check if the device is actually a recording device/microphone
                if !actual_devices.contains(&device_name) {
                    continue;
                }

                let pcm_cutted = pcm_id.to_string().split(":").nth(1).unwrap().to_string();
                working_pcms.insert(
                    0,
                    PCMAndName {
                        pcm_id: pcm_cutted.to_string(),
                        display_name: device_name,
                    },
                );

                pcm_id = "";
            } else {
                pcm_id = line.trim();
            }
        }

        // Third, assign the display names to the input devices and remove the ones that don't do anything
        input_devices.retain_mut(|device| {
            let mut found = false;
            for pcm in &working_pcms {
                if device.id.contains(&pcm.pcm_id) && device.id.starts_with("sysdefault:") {
                    device.display_name = pcm.display_name.clone();
                    found = true;
                }
            }
            found
        });
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
