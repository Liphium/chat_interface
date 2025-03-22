use std::{cmp, sync::Arc};

use audiopus::coder::Encoder;
use rand::Rng;
use tokio::sync::{mpsc::Receiver, Mutex};

use super::{AudioPacket, MicrophoneOptions};

pub struct EncodingEngine {
    encoder: Option<Mutex<Encoder>>,
    current_seq: u16,
}

impl EncodingEngine {
    // Start a new encoding engine
    pub fn create<F>(
        mut sample_receiver: Receiver<Vec<f32>>,
        options: Arc<Mutex<MicrophoneOptions>>,
        mut send_fn: F,
    ) -> Arc<Mutex<Self>>
    where
        F: FnMut(AudioPacket) + Send + 'static,
    {
        // Create a new Opus encoder for this encoding engine
        let encoder = Encoder::new(
            audiopus::SampleRate::Hz48000,
            audiopus::Channels::Mono,
            audiopus::Application::Voip,
        )
        .expect("Couldn't create opus encoder");

        let engine = Arc::new(Mutex::new(Self {
            encoder: Some(Mutex::new(encoder)),
            current_seq: rand::rng().random(),
        }));

        // Spawn the encoding task
        tokio::task::spawn_blocking({
            let engine = engine.clone();

            // State for voice activity detection
            let mut talking_streak = 0;
            let mut noise_floor = 0.0;

            // Constants for the automatic voice activity detection
            let alpha = 0.99;
            let threshold_factor = 1.7;

            move || loop {
                let samples: Option<Vec<f32>> = sample_receiver.blocking_recv();
                if samples.is_none() {
                    break;
                }
                let samples = samples.expect("Couldn't unwrap option even though some?");

                // Get the options for voice activity detection
                let options = options.blocking_lock();

                // Run voice activity detection (if desired)
                let mut speech = None;
                let mut amplitude = None;
                if options.activity_detection {
                    // Calculate the mean square root of the samples (or "energy", really useful for speech detection)
                    let mut avg = 0.0;
                    for sample in samples.iter() {
                        avg += sample * sample;
                    }
                    avg = avg / samples.len() as f32;
                    avg = avg.sqrt();

                    // Try to detect speech
                    let speech_detected: bool = if options.automatic_detection {
                        // TODO: Improve this maybe
                        // Use automatic detection by having a noise floor
                        noise_floor = alpha * noise_floor + (1.0 - alpha) * avg;
                        avg > noise_floor * threshold_factor
                    } else {
                        // Use the talking amplitude for speech detection
                        avg = pcm_to_db(avg);
                        amplitude = Some(avg);
                        avg > options.talking_amplitude
                    };

                    // Compute the current talking state
                    speech = Some(if speech_detected {
                        talking_streak = 25;
                        true
                    } else {
                        talking_streak = cmp::max(talking_streak - 1, 0);
                        talking_streak > 0
                    });
                }

                // Encode using Opus (only when speech is detected)
                let mut seq = 0;
                let mut packet = None;
                if speech.is_none() || speech.is_some_and(|s| s) {
                    let mut engine = engine.blocking_lock();
                    if engine.encoder.is_none() {
                        break;
                    }

                    // Increment the sequence number
                    if engine.current_seq == u16::MAX {
                        engine.current_seq = 0;
                    } else {
                        engine.current_seq += 1;
                    }

                    // Encode the packet
                    let encoder = engine.encoder.as_ref().unwrap();
                    let coder = encoder.blocking_lock();
                    let mut output = [0u8; 2000];
                    let output_size = coder
                        .encode_float(samples.as_slice(), &mut output)
                        .expect("Couldn't encode");
                    let (encoded, _) = output.split_at(output_size);

                    // Return the packet
                    packet = Some(encoded.to_vec());
                    seq = engine.current_seq;
                }

                // Send to the client
                send_fn(AudioPacket {
                    id: None,
                    speech: speech,
                    amplitude: amplitude,
                    packet: packet,
                    seq: seq,
                });
            }
        });

        return engine.clone();
    }

    // Stop the encoding engine
    pub fn stop(&mut self) {
        self.encoder = None;
    }
}

// Convert pcm data to decibel
fn pcm_to_db(pcm: f32) -> f32 {
    20.0 * pcm.abs().log10()
}
