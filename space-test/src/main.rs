use std::{any::Any, process::Command, thread, time::Duration};

use cpal::traits::{DeviceTrait, HostTrait};
use libspaceship::{api, connection};


fn main() {
    
    let host = cpal::default_host();
    let mut device_names = Vec::<String>::new();
    for device in host.input_devices().unwrap() {
                
        match device.name() {
            Ok(name) => device_names.insert(0, name),
            Err(_) => {}
        }
    }

    // Check for linux here or sth
    #[cfg(target_os = "linux")] 
    {

        let command = Command::new("arecord").arg("-l").output().expect("couldn't run"); 
        let output = String::from_utf8_lossy(&command.stdout);
        println!("{}", output);
        let mut actual_devices = Vec::<String>::new();

        // Get list of actual devices
        for line in output.split("\n") {
            if line.starts_with("card") {
                let device_name = line.trim().split(":").nth(1).unwrap().trim().split("[").nth(1).unwrap().trim().split("]").nth(0).unwrap().trim().to_string();
                actual_devices.insert(0, device_name);
            }
        }

        let command = Command::new("arecord").arg("-L").output().expect("couldn't run"); 
        let output = String::from_utf8_lossy(&command.stdout);
        
        // Filter all input devices
        let mut pcm_id = "";
        for line in output.split("\n") {
            if line.starts_with(" ") && pcm_id != "" {
                let device_name = line.trim().to_string();

                // Check if the device is actually a recording device/microphone
                if !actual_devices.contains(&device_name) {
                    continue;
                }
                let pcm_cutted = pcm_id.to_string().split(":").nth(1).unwrap().to_string();
                println!("{} | {} | {} | {}", device_name, &pcm_id, pcm_cutted, device_names.contains(&pcm_cutted));

                for device in device_names.iter() {
                    if device.contains(&pcm_cutted) && device.contains("sysdefault:") {
                        println!("Found device: {}", device);
                    }
                }

                pcm_id = "";
            } else {
                pcm_id = line.trim();
            }
        }

    }
    
    //connect_to_space_node();
}

pub fn connect_to_local_server() {
    libspaceship::logger::set_log_stdout(true);
    libspaceship::api::set_talking_amplitude(0.0f32);
    connection::udp::init();
    connection::udp::connect_read("localhost:3011")
}

pub fn connect_to_space_node() {
    libspaceship::logger::set_log_stdout(true);
    libspaceship::api::set_talking_amplitude(0.0f32);
    connection::udp::init();
    connection::udp::connect_read("128.140.35.38:4101")
}

pub fn test_voice() {
    api::test_voice(api::get_default_id());
    let mut tries = 0;
    loop {
        tries += 1;
        if tries >= 3 {
            break;
        }
        thread::sleep(Duration::from_secs(1));
    }
    api::stop();
    thread::sleep(Duration::from_secs(10));
}
