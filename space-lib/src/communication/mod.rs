use std::{io, collections::HashMap};

use serde::{Deserialize, Serialize};

use crate::{util, audio};

#[derive(Deserialize, Serialize)]
pub struct Event {
    pub action: String,
    pub data: HashMap<String, ()>
}

// General actions
const ACTION_DEAFEN: &str = "deafen";
const ACTION_UNDEAFEN: &str = "undeafen";
const ACTION_MUTE: &str = "mute";
const ACTION_UNMUTE: &str = "unmute";
const ACTION_SILENT_MUTE: &str = "silent_mute";
const ACTION_SILENT_UNMUTE: &str = "silent_unmute";
const ACTION_EXIT: &str = "exit";

// Application actions
const ACTION_TOGGLE_AMPLITUDE: &str = "toggle_amplitude";
const ACTION_SET_TALKING_AMPLITUDE: &str = "set_talking_amplitude";
// const ACTION_DEVICES: &str = "devices"; FUTURE
// const ACTION_SELECT_DEVICE: &str = "select_device"; FUTURE
 
// Start listening for console input (from the other application)
pub fn start_listening() -> ! {

    util::print_action(Event{
        action: "start_listening".to_string(),
        data: HashMap::new()
    });
    let mut input = String::new();

    loop {
        io::stdin().read_line(&mut input).expect("Failed to read line");
        input = input.trim().to_string();

        // ACTION:VALUE
        let mut unknown = false;
        match input.as_str().split(":").nth(0).unwrap() {
            ACTION_DEAFEN => {
                audio::set_deafen(true);
            },

            ACTION_UNDEAFEN => {
                audio::set_deafen(false);
            },

            ACTION_MUTE => {
                audio::set_muted(true);
            },

            ACTION_UNMUTE => {
                audio::set_muted(false);
            },

            ACTION_SILENT_MUTE => {
                audio::set_silent_mute(true);
            },

            ACTION_SILENT_UNMUTE => {
                audio::set_silent_mute(false);
            },

            ACTION_EXIT => {
                util::print_log("Thanks for using Fajurion Voice!");
                std::process::exit(0);
            },

            ACTION_TOGGLE_AMPLITUDE => {
                let amplitude_logging = !audio::is_amplitude_logging();
                audio::set_amplitude_logging(amplitude_logging);
            },

            ACTION_SET_TALKING_AMPLITUDE => {
                let amplitude = input.as_str().split(":").nth(1).unwrap().parse::<f32>().unwrap();
                audio::set_talking_amplitude(amplitude);
            },

            action => {
                util::print_log(format!("Unknown action: {}", action).as_str());
                unknown = true;
            }
        }

        // Send feedback
        if !unknown {
            util::print_action(Event{
                action: input.split(":").nth(0).unwrap().to_string(),
                data: HashMap::new()
            })
        }

        input.clear();
    }
}