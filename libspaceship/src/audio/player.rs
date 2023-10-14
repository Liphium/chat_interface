use std::{sync::{Arc, Mutex}, time::{Instant, Duration}, collections::VecDeque};

use audiopus::coder;
use rodio::{Sink, buffer::SamplesBuffer};
use tokio::sync::mpsc::{Receiver, Sender};

use crate::{connection::Protocol, logger};

use super::decode::{AudioPacket, self};

pub struct DecodedAudioPacket {
    pub samples: Vec<f32>,
    pub protocol: Protocol,
}

pub fn start_audio_player(handle: &tokio::runtime::Handle, sink: Arc<Mutex<Sink>>, mut receiver: Receiver<DecodedAudioPacket>) {
    handle.spawn(async move {

        let mut current_protocol = Protocol::None;
        let mut current_interval = tokio::time::interval(Duration::from_millis(20));

        loop {
            current_interval.tick().await;

            let packet = match receiver.try_recv() {
                Ok(packet) => packet,
                Err(_) => {
                    //logger::send_log(logger::TAG_AUDIO, "No packet received");
                    continue;
                },
            };

            if packet.protocol != current_protocol {
                current_protocol = packet.protocol.clone();
                current_interval = tokio::time::interval(packet.protocol.frame_duration());
                continue;
            }

            let sink_locked = match sink.lock() {
                Ok(sink) => sink,
                Err(_) => {
                    logger::send_log(logger::TAG_AUDIO, "Failed to acquire lock on sink");
                    continue;
                },
            };

            sink_locked.append(SamplesBuffer::new(1, current_protocol.opus_sample_rate() as u32, packet.samples.as_slice()));
            drop(sink_locked);
        }

    });
}

pub const BUFFER_SIZE: usize = 4; // 80ms normally

pub fn start_audio_processor(handle: &tokio::runtime::Handle, mut receiver: Receiver<AudioPacket>, sender: Sender<DecodedAudioPacket>) {
    handle.spawn(async move {

        let mut current_protocol = Protocol::None;
        let mut decoder = coder::Decoder::new(audiopus::SampleRate::Hz48000, audiopus::Channels::Mono).unwrap();
        let mut jitter_buffer = VecDeque::with_capacity(BUFFER_SIZE);
        let mut last_played_seq: u32 = 0;
        let mut last_packet = Instant::now();

        loop {
            let packet = receiver.recv().await.unwrap();
            let seq = packet.seq;

            if packet.protocol != current_protocol {
                decoder = coder::Decoder::new(packet.protocol.opus_sample_rate(), audiopus::Channels::Mono).unwrap();
                current_protocol = packet.protocol.clone();
                continue;
            }
            let decoded = decode::decode(packet.data.as_slice(), super::encode::FRAME_SIZE, &mut decoder);

            // Add the packet to the jitter buffer
            if Instant::now().duration_since(last_packet) > Duration::from_millis(100) {
                logger::send_log(logger::TAG_AUDIO, "A long time has passed, clearing buffer");
                jitter_buffer.clear();
            }
            last_packet = Instant::now();

            jitter_buffer.push_back((seq, decoded));
            if jitter_buffer.len() > BUFFER_SIZE {
                jitter_buffer.pop_front();
            } else if jitter_buffer.len() != BUFFER_SIZE {
                logger::send_log(logger::TAG_AUDIO, "Jitter buffer too small, dropping packet");
                continue;
            }

            // Make sure something is always playing
            let (front_seq, _) = jitter_buffer.front().unwrap();
            if last_played_seq == 0 || last_played_seq.wrapping_sub(*front_seq) > BUFFER_SIZE as u32 {
                logger::send_log(logger::TAG_AUDIO, format!("Last played: {}, front: {}", last_played_seq, front_seq).as_str());
                last_played_seq = *front_seq - 1;
            }

            // Check if the next packet in the buffer is ready to be played
            let index = match jitter_buffer.iter().position(|(seq, _)| *seq == last_played_seq + 1) {
                Some(index) => index,
                None => {
                    logger::send_log(logger::TAG_AUDIO, format!("Last played: {}, nothing found, incrementing", last_played_seq).as_str());
                    last_played_seq += 1;
                    continue;
                },
            };
            let (next_seq, next_decoded) = match jitter_buffer.get(index.clone()) {
                Some((seq, decoded)) => (seq.clone(), decoded.clone()),
                None => continue,
            };
            logger::send_log(logger::TAG_AUDIO, format!("Last played: {}, now playing: {}", last_played_seq, next_seq).as_str());
            jitter_buffer.remove(index);

            sender.try_send(DecodedAudioPacket { 
                samples: next_decoded.clone(), 
                protocol: current_protocol.clone(), 
            }).unwrap();

            last_played_seq = next_seq;

            // let sink_locked = match sink.lock() {
            //     Ok(sink) => sink,
            //     Err(_) => {
            //         logger::send_log(logger::TAG_AUDIO, "Failed to acquire lock on sink");
            //         continue;
            //     },
            // };
            

            // sink_locked.append(SamplesBuffer::new(1, packet.protocol.opus_sample_rate() as u32, decoded));
            // drop(sink_locked)
        }
    });
}