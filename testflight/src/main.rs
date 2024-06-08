use std::{collections::HashMap, thread, time::Duration};

use rust_lib::{api, logger};

fn main() {
    let input = "
    null
        Discard all samples (playback) or generate zero samples (capture)
    lavrate
        Rate Converter Plugin Using Libav/FFmpeg Library
    samplerate
        Rate Converter Plugin Using Samplerate Library
    speexrate
        Rate Converter Plugin Using Speex Resampler
    jack
        JACK Audio Connection Kit
    oss
        Open Sound System
    pipewire
        PipeWire Sound Server
    pulse
        PulseAudio Sound Server
    speex
        Plugin using Speex DSP (resample, agc, denoise, echo, dereverb)
    upmix
        Plugin for channel upmix (4,6,8)
    vdownmix
        Plugin for channel downmix (stereo) with a simple spacialization
    default
        Default ALSA Output (currently PipeWire Media Server)
    sysdefault:CARD=Generic
        HD-Audio Generic, ALC1220 Analog
        Default Audio Device
    sysdefault:CARD=Wireless
        HyperX Cloud II Wireless, USB Audio
        Default Audio Device
    sysdefault:CARD=Snowball
        Blue Snowball, USB Audio
        Default Audio Device
    sysdefault:CARD=Webcam
        C922 Pro Stream Webcam, USB Audio
        Default Audio Device";

    // Testing a parser
    let mut pcm_to_device: HashMap<&str, &str> = HashMap::new();
    let lines: Vec<&str> = input.lines().collect();
    let mut index = 0;

    for line in lines.clone() {
        if line.trim().starts_with("sysdefault:CARD=") {
            let mut iter = line.split("CARD=");
            if let Some(current_pcm) = iter.nth(1) {
                let device_name = lines
                    .get(index + 1)
                    .expect("this cannot fail basically")
                    .trim()
                    .split(", ")
                    .nth(0)
                    .unwrap();
                pcm_to_device.insert(current_pcm, device_name);
            }
        }
        index += 1;
    }

    println!("PCM to Device:");
    for (pcm, device) in pcm_to_device {
        println!("{} -> {}", pcm, device);
    }

    logger::set_log_stdout(true);

    api::interaction::set_input_device("surround71:CARD=Generic,DEV=0".to_string());

    api::interaction::test_voice("def".to_string(), 0);

    loop {
        thread::sleep(Duration::from_millis(1000));
    }
}
