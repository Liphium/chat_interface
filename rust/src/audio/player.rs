use std::{
    collections::VecDeque,
    sync::Arc,
    time::{Duration, Instant},
};

use audiopus::coder;
use rodio::Sink;
use tokio::sync::{mpsc::Receiver, Mutex};

use crate::{connection::Protocol, logger};

use super::decode::{self, AudioPacket};

#[derive(Clone)]
pub struct DecodedAudioPacket {
    pub samples: Vec<f32>,
    pub protocol: Protocol,
}

pub fn start_audio_player(
    handle: &tokio::runtime::Handle,
    sink: Arc<std::sync::Mutex<Sink>>,
    jitter_buffer: Arc<Mutex<VecDeque<(u32, DecodedAudioPacket)>>>,
) {
    handle.spawn(async move {
        let mut current_protocol = Protocol::None;
        let mut current_interval = tokio::time::interval(Duration::from_millis(20));
        let mut last_seq: u32 = 0;

        loop {
            current_interval.tick().await;

            // Evaluate jitter buffer
            let mut jitter_buffer_vec = jitter_buffer.lock().await;
            println!("{} {}", jitter_buffer_vec.len(), last_seq);
            if jitter_buffer_vec.len() > BUFFER_SIZE {
                jitter_buffer_vec.pop_front();
            }

            if jitter_buffer_vec.len() < BUFFER_SIZE / 2 {
                last_seq = 0;
                continue;
            }

            if last_seq == 0 {
                last_seq = jitter_buffer_vec
                    .clone()
                    .into_iter()
                    .min_by(|x, y| x.0.cmp(&y.0))
                    .unwrap()
                    .0;
            } else {
                last_seq += 1;
            }

            // Play the thing
            // if packet.protocol != current_protocol {
            //     current_protocol = packet.protocol.clone();
            //     current_interval = tokio::time::interval(packet.protocol.frame_duration());
            //     continue;
            // }

            // let sink_locked = match sink.try_lock() {
            //     Ok(sink) => sink,
            //     Err(_) => {
            //         logger::send_log(logger::TAG_AUDIO, "Failed to acquire lock on sink");
            //         continue;
            //     }
            // };

            // sink_locked.append(SamplesBuffer::new(
            //     1,
            //     current_protocol.opus_sample_rate() as u32,
            //     packet.samples.as_slice(),
            // ));
            // drop(sink_locked);
        }
    });
}

pub static BUFFER_SIZE: usize = 30;

pub fn start_audio_processor(
    handle: &tokio::runtime::Handle,
    mut receiver: Receiver<AudioPacket>,
    jitter_buffer: Arc<Mutex<VecDeque<(u32, DecodedAudioPacket)>>>,
) {
    handle.spawn(async move {
        let mut current_protocol = Protocol::None;
        let mut decoder =
            coder::Decoder::new(audiopus::SampleRate::Hz48000, audiopus::Channels::Mono).unwrap();
        let mut last_packet = Instant::now();

        loop {
            let packet = receiver.recv().await.unwrap();
            let seq = packet.seq;

            if packet.protocol != current_protocol {
                decoder = coder::Decoder::new(
                    packet.protocol.opus_sample_rate(),
                    audiopus::Channels::Mono,
                )
                .unwrap();
                current_protocol = packet.protocol.clone();
                logger::send_log(logger::TAG_AUDIO, "different protocol found");
                continue;
            }
            let decoded = decode::decode(
                packet.data.as_slice(),
                super::encode::FRAME_SIZE,
                &mut decoder,
            );

            // Aquire lock on the jitter buffer
            let mut jitter_buffer_vec = jitter_buffer.lock().await;

            // Add the packet to the jitter buffer
            if Instant::now().duration_since(last_packet) > Duration::from_millis(100) {
                logger::send_log(logger::TAG_AUDIO, "A long time has passed, clearing buffer");
                jitter_buffer_vec.clear();
            }
            last_packet = Instant::now();

            // Push packet into the jitter buffer
            jitter_buffer_vec.push_back((
                seq,
                DecodedAudioPacket {
                    protocol: packet.protocol,
                    samples: decoded,
                },
            ));
        }
    });
}
