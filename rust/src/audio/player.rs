use std::{
    collections::VecDeque,
    sync::Arc,
    time::{Duration, Instant},
};

use audiopus::coder;
use rodio::{buffer::SamplesBuffer, Sink};
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
    sink: Sink,
    jitter_buffer: Arc<Mutex<VecDeque<(u32, DecodedAudioPacket)>>>,
) {
    handle.spawn(async move {
        let mut current_protocol = Protocol::None;
        let mut current_interval = tokio::time::interval(Duration::from_millis(20));
        let mut current_seq: u32 = 0;

        let mut last_current_max = 0;
        let mut last_packet = Instant::now();

        loop {
            current_interval.tick().await;

            // Evaluate jitter buffer
            let mut jitter_buffer_vec = jitter_buffer.lock().await;

            if jitter_buffer_vec.len() < BUFFER_SIZE / 2 {
                current_seq = 0;
                continue;
            }

            let current_max = jitter_buffer_vec
                .clone()
                .into_iter()
                .max_by(|x, y| x.0.cmp(&y.0))
                .unwrap()
                .0;

            if current_max != last_current_max {
                last_current_max = current_max;
                last_packet = Instant::now();
            }

            if Instant::now().duration_since(last_packet).as_millis() > 100 {
                logger::send_log(
                    logger::TAG_AUDIO,
                    &format!(
                        "Dropping buffer cause delay: {}ms",
                        Instant::now().duration_since(last_packet).as_millis()
                    ),
                );
                jitter_buffer_vec.clear();
                continue;
            }

            if current_seq == 0 {
                current_seq = jitter_buffer_vec
                    .clone()
                    .into_iter()
                    .min_by(|x, y| x.0.cmp(&y.0))
                    .unwrap()
                    .0;
                println!("new seq: {}", current_seq);
            }

            let max_seq = jitter_buffer_vec
                .clone()
                .into_iter()
                .max_by(|x, y| x.0.cmp(&y.0))
                .unwrap()
                .0;

            let before_seq = current_seq.clone();
            let current_packet_result = jitter_buffer_vec
                .clone()
                .into_iter()
                .find(|x| x.0 == current_seq);

            if current_packet_result.is_none() {
                if jitter_buffer_vec
                    .clone()
                    .into_iter()
                    .find(|x| x.0 == current_seq + 1)
                    .is_none()
                {
                    logger::send_log(logger::TAG_AUDIO, "Major packet drops...")
                } else {
                    logger::send_log(logger::TAG_AUDIO, "Minor packet drop...");
                }
                continue;
            }

            let current_packet = current_packet_result.unwrap().1;

            if current_packet.protocol != current_protocol {
                current_protocol = current_packet.protocol.clone();
                current_interval = tokio::time::interval(current_packet.protocol.frame_duration());
            }

            sink.append(SamplesBuffer::new(
                1,
                current_protocol.usize() as u32,
                current_packet.samples.as_slice(),
            ));

            current_seq += 1;

            logger::send_log(
                logger::TAG_AUDIO,
                &format!(
                    "current: {}, max seq: {}, size: {}, inserted: {}",
                    current_seq,
                    max_seq,
                    jitter_buffer_vec.len(),
                    current_seq - before_seq
                ),
            );
        }
    });
}

pub static BUFFER_SIZE: usize = 40;

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
            let packet = receiver.recv().await.expect("couldn't receive packet");
            let seq = packet.seq;

            if packet.protocol != current_protocol {
                decoder = coder::Decoder::new(
                    packet.protocol.opus_sample_rate(),
                    audiopus::Channels::Mono,
                )
                .unwrap();
                current_protocol = packet.protocol.clone();
                logger::send_log(
                    logger::TAG_AUDIO,
                    &format!(
                        "different protocol found {:?}",
                        packet.protocol.opus_sample_rate()
                    ),
                );
                continue;
            }
            let decoded = decode::decode(
                packet.data.as_slice(),
                super::encode::FRAME_SIZE,
                &mut decoder,
            );

            // Aquire lock on the jitter buffer
            let mut jitter_buffer_vec = jitter_buffer.lock().await;
            if jitter_buffer_vec.len() >= BUFFER_SIZE {
                jitter_buffer_vec.pop_front();
            }

            if Instant::now().duration_since(last_packet).as_millis() > 100 {
                logger::send_log(
                    logger::TAG_AUDIO,
                    &format!(
                        "delay {}ms",
                        Instant::now().duration_since(last_packet).as_millis()
                    ),
                );
                println!("dropping buffer");
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
