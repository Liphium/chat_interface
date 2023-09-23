use std::sync::Mutex;
use once_cell::sync::Lazy;

pub mod microphone;
pub mod encode;
pub mod decode;

pub struct AudioOptions {
    pub silent_mute: bool,
    pub muted: bool,
    pub deafened: bool,
    pub amplitude_logging: bool,
    pub talking: bool,
    pub talking_amplitude: f32,
}

pub static AUDIO_OPTIONS: Lazy<Mutex<AudioOptions>> = Lazy::new(|| {
    Mutex::new(AudioOptions {
        silent_mute: false,
        muted: false,
        deafened: false,
        amplitude_logging: false,
        talking: false,
        talking_amplitude: 0.07,
    })
});

pub fn set_muted(muted: bool) {
    let mut options = AUDIO_OPTIONS.lock().unwrap();
    (*options).muted = muted;
}

pub fn set_deafen(deafened: bool) {
    let mut options = AUDIO_OPTIONS.lock().unwrap();
    (*options).deafened = deafened;
}

pub fn is_muted() -> bool {
    let options = AUDIO_OPTIONS.lock().unwrap();
    options.muted
}

pub fn is_deafened() -> bool {
    let options = AUDIO_OPTIONS.lock().unwrap();
    options.deafened
}

pub fn set_amplitude_logging(amplitude_logging: bool) {
    let mut options = AUDIO_OPTIONS.lock().unwrap();
    (*options).amplitude_logging = amplitude_logging;
}

pub fn is_amplitude_logging() -> bool {
    let options = AUDIO_OPTIONS.lock().unwrap();
    options.amplitude_logging
}

pub fn set_talking_amplitude(amplitude: f32) {
    let mut options = AUDIO_OPTIONS.lock().unwrap();
    (*options).talking_amplitude = amplitude;
}

pub fn get_talking_amplitude() -> f32 {
    let options = AUDIO_OPTIONS.lock().unwrap();
    options.talking_amplitude
}

pub fn set_silent_mute(silent_mute: bool) {
    let mut options = AUDIO_OPTIONS.lock().unwrap();
    (*options).silent_mute = silent_mute;
}

pub fn is_silent_mute() -> bool {
    let options = AUDIO_OPTIONS.lock().unwrap();
    options.silent_mute
}

pub fn is_talking() -> bool {
    let options = AUDIO_OPTIONS.lock().unwrap();
    options.talking
}