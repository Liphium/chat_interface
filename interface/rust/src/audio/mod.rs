use once_cell::sync::Lazy;
use std::sync::{self, Mutex};

use crate::api;

pub mod decode;
pub mod encode;
pub mod microphone;
pub mod player;

pub static ACTION_STARTED_TALKING: &str = "started_talking";
pub static ACTION_STOPPED_TALKING: &str = "stopped_talking";

pub struct AudioOptions {
    pub silent_mute: bool,
    pub muted: bool,
    pub deafened: bool,
    pub amplitude_logging: bool,
    pub talking: bool,
    pub talking_amplitude: f32,
    pub input_device: String,
    pub output_device: String,
}

pub static AUDIO_OPTIONS: Lazy<Mutex<AudioOptions>> = Lazy::new(|| {
    Mutex::new(AudioOptions {
        silent_mute: false,
        muted: false,
        deafened: false,
        amplitude_logging: false,
        talking: false,
        talking_amplitude: 0.07,
        input_device: String::from(api::interaction::DEFAULT_NAME),
        output_device: String::from(api::interaction::DEFAULT_NAME),
    })
});

pub fn get_options() -> sync::MutexGuard<'static, AudioOptions> {
    match AUDIO_OPTIONS.lock() {
        Ok(options) => options,
        Err(options) => options.into_inner(),
    }
}

pub fn set_muted(muted: bool) {
    let mut options = get_options();
    (*options).muted = muted;
}

pub fn set_deafen(deafened: bool) {
    let mut options = get_options();
    (*options).deafened = deafened;
}

pub fn is_muted() -> bool {
    let options = get_options();
    options.muted
}

pub fn is_deafened() -> bool {
    let options = get_options();
    options.deafened
}

pub fn set_amplitude_logging(amplitude_logging: bool) {
    let mut options = get_options();
    (*options).amplitude_logging = amplitude_logging;
}

pub fn is_amplitude_logging() -> bool {
    let options = get_options();
    options.amplitude_logging
}

pub fn set_talking_amplitude(amplitude: f32) {
    let mut options = get_options();
    (*options).talking_amplitude = amplitude;
}

pub fn get_talking_amplitude() -> f32 {
    let options = get_options();
    options.talking_amplitude
}

pub fn set_silent_mute(silent_mute: bool) {
    let mut options = get_options();
    (*options).silent_mute = silent_mute;
}

pub fn set_input_device(microphone: String) {
    let mut options = get_options();
    (*options).input_device = microphone;
}

pub fn get_input_device() -> String {
    let options = get_options();
    options.input_device.clone()
}

pub fn set_output_device(speaker: String) {
    let mut options = get_options();
    (*options).output_device = speaker;
}

pub fn get_output_device() -> String {
    let options = get_options();
    options.output_device.clone()
}

pub fn is_silent_mute() -> bool {
    let options = get_options();
    options.silent_mute
}

pub fn is_talking() -> bool {
    let options = get_options();
    options.talking
}
