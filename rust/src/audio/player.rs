use std::{collections::VecDeque, sync::Arc, time::Duration};

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
    sink: Arc<std::sync::Mutex<Sink>>,
    jitter_buffer: Arc<Mutex<VecDeque<(u32, DecodedAudioPacket)>>>,
) {
    handle.spawn(async move {
        let mut current_protocol = Protocol::None;
        let mut current_interval = tokio::time::interval(Duration::from_millis(20));

        loop {
            current_interval.tick().await;

            // Evaluate jitter buffer
            let mut jitter_buffer_vec = jitter_buffer.lock().await;
            if jitter_buffer_vec.len() > BUFFER_SIZE {
                jitter_buffer_vec.pop_front();
            }

            if jitter_buffer_vec.len() < BUFFER_SIZE {
                continue;
            }

            println!("playing");
            let mut current_seq = jitter_buffer_vec
                .clone()
                .into_iter()
                .min_by(|x, y| x.0.cmp(&y.0))
                .unwrap()
                .0;
            let max_seq = jitter_buffer_vec
                .clone()
                .into_iter()
                .max_by(|x, y| x.0.cmp(&y.0))
                .unwrap()
                .0;

            while current_seq != max_seq {
                let current_packet_result = jitter_buffer_vec
                    .clone()
                    .into_iter()
                    .find(|x| x.0 == current_seq);
                let current_packet = current_packet_result.unwrap().1;

                if current_packet.protocol != current_protocol {
                    current_protocol = current_packet.protocol.clone();
                    current_interval =
                        tokio::time::interval(current_packet.protocol.frame_duration());
                }

                let sink_locked = match sink.try_lock() {
                    Ok(sink) => sink,
                    Err(_) => {
                        logger::send_log(logger::TAG_AUDIO, "Failed to acquire lock on sink");
                        continue;
                    }
                };

                sink_locked.append(SamplesBuffer::new(
                    1,
                    current_protocol.opus_sample_rate() as u32,
                    current_packet.samples.as_slice(),
                ));
                drop(sink_locked);

                current_seq += 1;
            }
            jitter_buffer_vec.clear();

            println!("{} {}", current_seq, max_seq);
        }
    });
}

pub static BUFFER_SIZE: usize = 30;

pub fn start_audio_processor(
    handle: &tokio::runtime::Handle,
    mut receiver: Receiver<AudioPacket>,
    sink: Arc<std::sync::Mutex<Sink>>,
    jitter_buffer: Arc<Mutex<VecDeque<(u32, DecodedAudioPacket)>>>,
) {
    handle.spawn(async move {
        let mut current_protocol = Protocol::None;
        let mut decoder =
            coder::Decoder::new(audiopus::SampleRate::Hz48000, audiopus::Channels::Mono).unwrap();

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

            let sink_locked = match sink.try_lock() {
                Ok(sink) => sink,
                Err(_) => {
                    logger::send_log(logger::TAG_AUDIO, "Failed to acquire lock on sink");
                    continue;
                }
            };

            sink_locked.append(SamplesBuffer::new(
                1,
                current_protocol.opus_sample_rate() as u32,
                decoded,
            ));
            drop(sink_locked);

            /*
            // Push packet into the jitter buffer
            jitter_buffer_vec.push_back((
                seq,
                DecodedAudioPacket {
                    protocol: packet.protocol,
                    samples: decoded,
                },
            ));
            */
        }
    });
}
