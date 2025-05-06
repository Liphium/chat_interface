use cpal::traits::HostTrait;
use rodio::DeviceTrait;

use crate::lightwire::{self};

pub struct AudioInputDevice {
    pub name: String,
    pub system_default: bool,
}

/// Get all audio input devices on the system.
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

        // Add the parsed device to the list
        parsed_devices.push(AudioInputDevice {
            name: name,
            system_default: is_default,
        });
    }

    return parsed_devices;
}

// Get the default input device
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
    };
}

pub struct AudioOuputDevice {
    pub name: String,
    pub system_default: bool,
}

/// Get all audio output devices on the system.
pub fn get_output_devices() -> Vec<AudioOuputDevice> {
    let host = lightwire::get_preferred_host();
    let default_device_name = match host.default_output_device() {
        Some(device) => device.name().expect("Couldn't get default device name"),
        None => "-".to_string(),
    };

    // Parse all of the devices
    let mut parsed_devices = Vec::<AudioOuputDevice>::new();
    for device in host.output_devices().expect("Couldn't get output devices") {
        let name = device.name().expect("Couldn't get device name");
        let is_default = name == default_device_name;

        // Add the parsed device to the list
        parsed_devices.push(AudioOuputDevice {
            name: name,
            system_default: is_default,
        });
    }

    return parsed_devices;
}

// Get the default input device
pub fn get_default_output_device() -> AudioOuputDevice {
    let host = lightwire::get_preferred_host();
    let default_device = host
        .default_output_device()
        .expect("No default device found!");
    return AudioOuputDevice {
        name: default_device
            .name()
            .expect("No name found for default device"),
        system_default: true,
    };
}
