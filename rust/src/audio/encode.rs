use std::{
    collections::{HashMap, VecDeque},
    sync::{
        mpsc::{self, Receiver, Sender},
        Arc, Mutex,
    },
    thread,
};

use crate::{audio, frb_generated::StreamSink, logger, util};
use once_cell::sync::Lazy;
use rodio::{OutputStream, Sink};
use tokio::runtime::Runtime;

use crate::connection;

use super::{
    decode::AudioPacket,
    player::{self, start_audio_player, start_audio_processor},
};

pub const FRAME_SIZE: usize = 960;

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

pub fn encode(samples: Vec<f32>, encoder: &mut audiopus::coder::Encoder) -> Vec<u8> {
    let mut output: Vec<u8> = vec![0u8; 3000];

    return match encoder.encode_float(&samples, &mut output) {
        Ok(size) => output.split_at(size).0.to_vec(),
        Err(err) => panic!("error encoding: {}", err),
    };
}

static ENCODE_SENDER: Lazy<Mutex<Sender<Vec<f32>>>> = Lazy::new(|| {
    let (sender, _) = mpsc::channel();
    Mutex::new(sender)
});

static ENCODE_RECEIVER: Lazy<Mutex<Receiver<Vec<f32>>>> = Lazy::new(|| {
    let (_, receiver) = mpsc::channel();
    Mutex::new(receiver)
});

pub fn pass_to_encode(data: Vec<f32>) {
    ENCODE_SENDER
        .lock()
        .expect("channel kaputt")
        .send(data)
        .expect("sending kaputt");
}

pub fn encode_thread(config: Arc<connection::Config>, channels: usize) {
    // Encode channel
    let (sender, receiver) = mpsc::channel();
    let mut actual_sender = match ENCODE_SENDER.lock() {
        Ok(lock) => lock,
        Err(poisoned) => poisoned.into_inner(),
    };
    *actual_sender = sender;
    let mut actual_receiver = match ENCODE_RECEIVER.lock() {
        Ok(lock) => lock,
        Err(poisoned) => poisoned.into_inner(),
    };
    *actual_receiver = receiver;

    let opus_channel = match channels {
        1 => audiopus::Channels::Mono,
        2 => audiopus::Channels::Stereo,
        _ => panic!("invalid channel count"),
    };

    // Spawn a thread
    thread::spawn(move || {
        // Create encoder
        let mut protocol = connection::get_protocol();
        let mut encoder = audiopus::coder::Encoder::new(
            connection::get_protocol().opus_sample_rate(),
            opus_channel,
            audiopus::Application::Voip,
        )
        .unwrap();
        let mut buffer: Vec<u8> = Vec::<u8>::with_capacity(8000);
        let mut talking_streak = 0;
        let mut sequence = 0u32;

        // Set the bitrate to 128 kb/s
        encoder
            .set_bitrate(audiopus::Bitrate::BitsPerSecond(128000))
            .unwrap();

        let (mut _stream, stream_handle) = OutputStream::try_default().unwrap();
        let mut players: HashMap<String, tokio::sync::mpsc::Sender<AudioPacket>> = HashMap::new();
        let runtime: Runtime = Runtime::new().unwrap();

        loop {
            if connection::should_stop() {
                return;
            }

            if protocol != connection::get_protocol() {
                logger::send_log(
                    logger::TAG_AUDIO,
                    "Restarted encoding channel with new protocol.",
                );
                protocol = connection::get_protocol();
                encoder = audiopus::coder::Encoder::new(
                    connection::get_protocol().opus_sample_rate(),
                    opus_channel,
                    audiopus::Application::Voip,
                )
                .unwrap();
            }

            let samples = match ENCODE_RECEIVER.lock() {
                Ok(lock) => lock.recv().expect("receiving broken"),
                Err(poisoned) => poisoned.into_inner().recv().expect("receiving broken"),
            };
            let samples_len = samples.len();

            if samples_len < FRAME_SIZE * channels {
                logger::send_log(logger::TAG_AUDIO, "packet dropped");
                continue;
            }

            let mut options = audio::get_options();

            let mut max = 0.0;
            for sample in samples.iter() {
                if *sample > max {
                    max = *sample;
                }
            }

            if options.amplitude_logging {
                let mut sink = AMPLITUDE_SINK.lock().unwrap();
                if let Some(s) = &mut *sink {
                    s.add(max).expect("couldn't log amplitude");
                }
            }

            if max > options.talking_amplitude {
                talking_streak = 25;

                if !options.talking {
                    logger::send_log(logger::TAG_AUDIO, "Started talking.");
                    util::print_action(audio::ACTION_STARTED_TALKING);
                }
                options.talking = true;
            } else if talking_streak <= 0 {
                if options.talking {
                    logger::send_log(logger::TAG_AUDIO, "Stopped talking.");
                    util::print_action(audio::ACTION_STOPPED_TALKING);
                }
                options.talking = false;
            } else {
                talking_streak -= 1;
            }

            let encoded = encode(samples.clone(), &mut encoder);
            if !config.test
                && config.connection
                && !options.muted
                && !options.silent_mute
                && options.talking
            {
                sequence += 1;
                connection::construct_packet(&config, &protocol, &encoded, sequence, &mut buffer);
                connection::udp::send(buffer.clone());
            } else if config.test {
                sequence += 1;

                let item = players.entry(config.client_id.clone()).or_insert_with(|| {
                    let (packet_sender, packet_receiver) = tokio::sync::mpsc::channel(10usize);
                    let jitter_buffer = Arc::new(tokio::sync::Mutex::new(VecDeque::with_capacity(
                        player::BUFFER_SIZE,
                    )));
                    let sink = Sink::try_new(&stream_handle).expect("Couldn't create sink");
                    start_audio_player(runtime.handle(), sink, jitter_buffer.clone());
                    start_audio_processor(runtime.handle(), packet_receiver, jitter_buffer.clone());
                    packet_sender
                });
                item.try_send(AudioPacket {
                    protocol: protocol.clone(),
                    data: encoded,
                    id: config.client_id.clone(),
                    seq: sequence,
                })
                .unwrap_or_default();
            }
        }
    });
}
