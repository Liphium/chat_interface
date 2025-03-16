use std::sync::Arc;

use audiopus::coder::Encoder;
use rand::Rng;
use tokio::sync::{mpsc::Receiver, Mutex};

use super::AudioPacket;

pub struct EncodingEngine {
    encoder: Option<Mutex<Encoder>>,
    current_seq: u16,
}

impl EncodingEngine {
    // Start a new encoding engine
    pub fn create<F>(mut sample_receiver: Receiver<Vec<f32>>, mut send_fn: F) -> Arc<Mutex<Self>>
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
            move || loop {
                let sample: Option<Vec<f32>> = sample_receiver.blocking_recv();
                if sample.is_none() {
                    break;
                }

                // Get the encoder from the engine
                let mut engine = engine.blocking_lock();
                if engine.encoder.is_none() {
                    break;
                }
                if engine.current_seq == u16::MAX {
                    engine.current_seq = 0;
                } else {
                    engine.current_seq += 1;
                }
                let encoder = engine.encoder.as_ref().unwrap();
                let coder = encoder.blocking_lock();

                // Encode using Opus
                let mut output = [0u8; 2000];
                let output_size = coder
                    .encode_float(sample.unwrap().as_slice(), &mut output)
                    .expect("Couldn't encode");

                let (packet, _) = output.split_at(output_size);
                send_fn(AudioPacket {
                    id: None,
                    packet: packet.to_vec(),
                    seq: engine.current_seq,
                });
            }
        });

        return engine.clone();
    }
}
