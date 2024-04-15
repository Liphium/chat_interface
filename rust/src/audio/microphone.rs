use std::{sync::Mutex, thread, time::Duration};

use cpal::{
    traits::{DeviceTrait, HostTrait, StreamTrait},
    StreamConfig,
};
use once_cell::sync::Lazy;
use voice_activity_detector::VoiceActivityDetector;

use crate::{frb_generated::StreamSink, logger, util};

static STOP_CHAT: Lazy<Mutex<bool>> = Lazy::new(|| Mutex::new(false));
static AMPLITUDE_SINK: Lazy<Mutex<Option<StreamSink<f32>>>> = Lazy::new(|| Mutex::new(None));

pub fn set_amplitude_sink(s: StreamSink<f32>) {
    let mut sink = AMPLITUDE_SINK.lock().unwrap();
    *sink = Some(s);
    drop(sink);
}

pub fn delete_sink() {
    let mut sink = AMPLITUDE_SINK.lock().unwrap();
    *sink = None;
    drop(sink);
}

pub fn allow_start() {
    *STOP_CHAT.lock().unwrap() = false;
}

pub fn should_stop() -> bool {
    *STOP_CHAT.lock().unwrap()
}

pub fn stop() {
    *STOP_CHAT.lock().unwrap() = true;
}

fn pcm_to_db(pcm: f32) -> f32 {
    if pcm <= 0.0 {
        return -100.0;
    }
    20.0 * pcm.log10()
}

pub fn record() {
    thread::spawn(move || {
        // Get a cpal host
        let mut host = cpal::default_host(); // Current host on computer
        #[cfg(target_os = "linux")]
        {
            host = cpal::host_from_id(cpal::HostId::Jack).unwrap();
        }

        // Get input device (using new API)
        let mut device = host
            .default_input_device()
            .expect("no input device available"); // Current device
        for d in host.input_devices().expect("Couldn't get input devices") {
            if d.name().unwrap() == super::get_input_device() {
                device = d;
                break;
            }
        }
        let last_value = super::get_input_device();

        // Create a stream config
        let default_config = device
            .default_input_config()
            .expect("no stream config found");
        logger::send_log(
            logger::TAG_AUDIO,
            format!("default config: {:?}", default_config).as_str(),
        );
        let sample_rate: u32 = default_config.sample_rate().0;
        let _work_channels = 1; // Stereo doesn't work at the moment (will fix in the future or never)
        let mic_channels = default_config.channels();
        let config: StreamConfig = StreamConfig {
            channels: mic_channels,
            sample_rate: cpal::SampleRate(sample_rate),
            buffer_size: cpal::BufferSize::Fixed(2048),
        };

        let mut vad = VoiceActivityDetector::builder()
            .sample_rate(sample_rate)
            .chunk_size(2048usize)
            .build()
            .expect("how dare you");

        // Create a stream
        let mut historic_probability = vec![0.0f32; 10];
        let mut talking_streak = 0;
        let stream = match device.build_input_stream(
            &config.into(),
            move |data: &[f32], _: &_| {
                let samples = if mic_channels == 2 {
                    stereo_to_mono(data)
                } else {
                    data.to_vec()
                };

                let mut max = 0.0;
                for sample in samples.iter() {
                    if *sample > max {
                        max = *sample;
                    }
                }
                max = pcm_to_db(max);

                let mut options = super::get_options();

                if options.amplitude_logging {
                    let mut sink = AMPLITUDE_SINK.lock().unwrap();
                    if let Some(s) = &mut *sink {
                        s.add(max).expect("couldn't log amplitude");
                    }
                }

                // Linux is generally fine with 0.35 as well
                // macOS default value: 0.35

                // Detect if the user is talking
                let talking: bool = if options.detection_mode == 0 {
                    let probability = vad.predict(samples);

                    if historic_probability.len() > 10 {
                        historic_probability.remove(0);
                    }

                    historic_probability.push(probability);

                    probability > 0.45
                } else {
                    max > options.talking_amplitude
                };

                if talking {
                    talking_streak = 25;

                    if !options.talking {
                        logger::send_log(logger::TAG_AUDIO, "Started talking.");
                        util::print_action(super::ACTION_STARTED_TALKING);
                    }
                    options.talking = true;
                } else if talking_streak <= 0 {
                    if options.talking {
                        logger::send_log(logger::TAG_AUDIO, "Stopped talking."); // sadjasdasiodjasidjiasdiasjdaisjdiasdiasdjasdjaisd
                        util::print_action(super::ACTION_STOPPED_TALKING);
                    }
                    options.talking = false;
                } else {
                    talking_streak -= 1;
                }
            },
            move |err| {
                logger::send_log(
                    logger::TAG_ERROR,
                    format!("an error occurred on stream: {}", err).as_str(),
                );
            },
            None,
        ) {
            Ok(stream) => stream,
            Err(err) => {
                logger::send_log(
                    logger::TAG_ERROR,
                    format!("an error occurred on stream: {}", err).as_str(),
                );
                return;
            }
        };

        // Play the stream
        stream.play().unwrap();

        loop {
            if last_value != super::get_input_device() {
                logger::send_log(
                    logger::TAG_AUDIO,
                    format!(
                        "Input device changed to {}, restarting",
                        super::get_input_device()
                    )
                    .as_str(),
                );
                record();
                break;
            }

            if should_stop() {
                break;
            }

            thread::sleep(Duration::from_millis(100));
        }
    });
}

// From copilot chat
fn stereo_to_mono(pcm: &[f32]) -> Vec<f32> {
    let mut mono = Vec::with_capacity(pcm.len() / 2);
    for i in (0..pcm.len()).step_by(2) {
        let left = pcm[i];
        let right = pcm[i + 1];
        mono.push((left + right) * 0.5)
    }
    mono
}
