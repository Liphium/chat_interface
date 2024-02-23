use std::{
    collections::{HashMap, VecDeque},
    sync::{
        mpsc::{self, Receiver, Sender},
        Arc, Mutex,
    },
    thread,
    time::{Duration, SystemTime},
};

use audiopus::coder::{self};
use cpal::traits::HostTrait;
use once_cell::sync::Lazy;
use rodio::{DeviceTrait, OutputStream, Sink};
use tokio::runtime::Runtime;

use crate::{
    api,
    connection::{self, Protocol},
    logger,
    util::{self, crypto},
};

use super::player::{self, start_audio_player, start_audio_processor};

pub fn decode(
    samples: &[u8],
    buffer_size: usize,
    decoder: &mut audiopus::coder::Decoder,
) -> Vec<f32> {
    let mut output: Vec<f32> = vec![0f32; buffer_size];

    return match decoder.decode_float(Some(samples), &mut output, false) {
        Ok(size) => output.split_at(size).0.to_vec(),
        Err(err) => panic!("error decoding: {}", err),
    };
}

pub struct AudioPacket {
    pub protocol: Protocol,
    pub data: Vec<u8>,
    pub id: String,
    pub seq: u32,
}

static RECEIVE_SENDER: Lazy<Mutex<Sender<Vec<u8>>>> = Lazy::new(|| {
    let (sender, _) = mpsc::channel();
    Mutex::new(sender)
});

static RECEIVE_RECEIVER: Lazy<Mutex<Receiver<Vec<u8>>>> = Lazy::new(|| {
    let (_, receiver) = mpsc::channel();
    Mutex::new(receiver)
});

pub fn send_packet(packet: Vec<u8>) {
    RECEIVE_SENDER
        .lock()
        .expect("channel kaputt")
        .send(packet)
        .expect("sending kaputt");
}

pub struct PlayerInfo {
    pub receiver: tokio::sync::mpsc::Receiver<AudioPacket>,
    pub decoder: coder::Decoder,
}

// Starts a thread that decodes and plays the audio
pub fn decode_play_thread(config: Arc<connection::Config>) {
    // Receive channel
    let (sender, receiver) = mpsc::channel();
    let mut actual_sender = match RECEIVE_SENDER.lock() {
        Ok(sender) => sender,
        Err(sender) => sender.into_inner(),
    };
    *actual_sender = sender;
    let mut actual_receiver = match RECEIVE_RECEIVER.lock() {
        Ok(receiver) => receiver,
        Err(receiver) => receiver.into_inner(),
    };
    *actual_receiver = receiver;

    thread::spawn(move || {
        let host = cpal::default_host();
        let mut device = host.default_output_device().expect("No device available");
        for d in host.output_devices().expect("Couldn't get output devices") {
            if d.name().unwrap() == super::get_output_device() {
                device = d;
                break;
            }
        }
        let mut last_value = super::get_output_device();

        logger::send_log(
            logger::TAG_AUDIO,
            format!("Output device: {}", device.name().unwrap()).as_str(),
        );
        let (mut _stream, mut stream_handle) =
            OutputStream::try_from_device(&device).expect("Couldn't start output stream");
        let mut players: HashMap<String, tokio::sync::mpsc::Sender<AudioPacket>> = HashMap::new();
        let mut talking: HashMap<String, SystemTime> = HashMap::new();
        let runtime = Runtime::new().unwrap();

        //let mut last_packet = SystemTime::now();

        loop {
            if super::get_output_device() != last_value {
                for d in host.output_devices().expect("Couldn't get output devices") {
                    if d.name().unwrap() == super::get_output_device() {
                        device = d;
                        break;
                    }
                }
                logger::send_log(
                    logger::TAG_AUDIO,
                    format!("Output device changed to: {}", device.name().unwrap()).as_str(),
                );
                drop(_stream);
                last_value = super::get_output_device();
                (_stream, stream_handle) =
                    OutputStream::try_from_device(&device).expect("Couldn't start output stream");
                players.clear();
            }

            if connection::should_stop() {
                break;
            }

            // Filter talking array
            let now = SystemTime::now();
            let keys_to_remove: Vec<String> = talking
                .iter()
                .filter(|(_, value)| now.duration_since(**value).unwrap().as_millis() > 150)
                .map(|(key, _)| key.clone())
                .collect();

            for key in keys_to_remove {
                logger::send_log(logger::TAG_AUDIO, "stopped talking");
                util::send_action(api::interaction::Action {
                    action: super::ACTION_STOPPED_TALKING.to_string(),
                    data: key.clone(),
                });
                talking.remove(&key);
            }

            let packet_result = match RECEIVE_RECEIVER.lock() {
                Ok(receiver) => receiver,
                Err(receiver) => receiver.into_inner(),
            }
            .recv_timeout(Duration::from_millis(100));
            if packet_result.is_err() {
                continue;
            }

            // Split voice and sender data
            let unpacked = packet_result.unwrap();
            let (enc_sender_id, voice) = unpacked.split_at(38);
            let sender_id = crypto::decrypt(&config.verification_key, enc_sender_id);

            let decrypted = util::crypto::decrypt_sodium(&config.encryption_key, voice);
            if decrypted.is_err() {
                logger::send_log(
                    logger::TAG_CONNECTION,
                    "error decrypting a packet, maybe just a UDP packet drop error?",
                );
                continue;
            }
            let decrypted = decrypted.unwrap();

            let (protocol, voice_and_seq) = decrypted.split_at(2);
            let (seq_bytes, voice_data) = voice_and_seq.split_at(4);
            let seq = u32::from_be_bytes(seq_bytes.try_into().unwrap());
            let prefix = String::from_utf8(protocol.to_vec()).unwrap();

            // Decode (if decoder available)
            let protocol_option = connection::protocol_from_prefix(prefix.as_str());
            if protocol_option == None {
                continue;
            }
            let protocol = protocol_option.unwrap();

            let packet = AudioPacket {
                protocol: protocol.clone(),
                data: voice_data.to_vec(),
                id: String::from_utf8(sender_id).unwrap(),
                seq: seq,
            };

            let prev = talking.insert(packet.id.clone(), SystemTime::now());
            if prev == None {
                util::send_action(api::interaction::Action {
                    action: super::ACTION_STARTED_TALKING.to_string(),
                    data: packet.id.clone(),
                });
            }

            let item = players.entry(packet.id.clone()).or_insert_with(|| {
                let (packet_sender, packet_receiver) = tokio::sync::mpsc::channel(10usize);
                let jitter_buffer = Arc::new(tokio::sync::Mutex::new(VecDeque::with_capacity(
                    player::BUFFER_SIZE,
                )));
                let sink = Sink::try_new(&stream_handle).expect("Couldn't create sink");
                start_audio_player(runtime.handle(), sink, jitter_buffer.clone());
                start_audio_processor(runtime.handle(), packet_receiver, jitter_buffer.clone());
                packet_sender
            });
            item.try_send(packet).unwrap_or_default();

            // if item.protocol != protocol {
            //     decoders.remove(&packet.id);
            //     continue;
            // }

            // //logger::send_log(logger::TAG_AUDIO, format!("delay {}ns", SystemTime::now().duration_since(last_packet).unwrap().as_nanos()).as_str());
            // //last_packet = SystemTime::now();
            // sink.append(SamplesBuffer::new(1, protocol.opus_sample_rate() as u32, decoded));
        }
    });
}
