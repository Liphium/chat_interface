use cpal::traits::HostTrait;
use rodio::DeviceTrait;

use crate::lightwire::{self};

pub struct AudioInputDevice {
    pub name: String,
    pub system_default: bool,
    pub rating: u32,
}

/// Get all audio input devices on the system.
#[flutter_rust_bridge::frb(sync)]
pub fn get_input_devices() -> Vec<AudioInputDevice> {
    let host = lightwire::get_preferred_host();
    let default_device_name = match host.default_input_device() {
        Some(device) => device.name().expect("Couldn't get default device name"),
        None => "-".to_string(),
    };

    // Parse all of the devices
    let mut parsed_devices = Vec::<AudioInputDevice>::new();
    for device in host.input_devices().expect("Couldn't get input devices") {
        let name = device.name().expect("Couldn't get device name");
        let is_default = name == default_device_name;

        // Calculate the rating from sample rate and channels
        let default_config = device
            .default_input_config()
            .expect("Couldn't get default config");
        let rating = default_config.sample_rate().0; // TODO: Maybe improve in the future?

        // Add the parsed device to the list
        parsed_devices.push(AudioInputDevice {
            name: name,
            system_default: is_default,
            rating: rating,
        });
    }

    return parsed_devices;
}

// Get the default input device
#[flutter_rust_bridge::frb(sync)]
pub fn get_default_input_device() -> AudioInputDevice {
    let host = lightwire::get_preferred_host();
    let default_device = host
        .default_input_device()
        .expect("No default device found!");
    return AudioInputDevice {
        name: default_device
            .name()
            .expect("No name found for default device"),
        system_default: true,
        rating: 0,
    };
}
