use std::{thread, sync::{Mutex, mpsc::{Sender, self, Receiver}}, collections::HashMap, time::{Duration, SystemTime}};

use audiopus::coder::{self};
use cpal::{traits::HostTrait};
use once_cell::sync::Lazy;
use rodio::{Sink, OutputStream, buffer::SamplesBuffer, DeviceTrait};

use crate::{audio, connection::{self, Protocol}, util, api, logger};

pub fn decode(samples: &[u8], buffer_size: usize, decoder: &mut audiopus::coder::Decoder) -> Vec<f32> {

    let mut output: Vec<f32> = vec![0f32; buffer_size];

    return match decoder.decode_float(Some(samples), &mut output, false) {
        Ok(size) => {
            output.split_at(size).0.to_vec()
        },
        Err(err) => panic!("error decoding: {}", err)
    };
}

pub struct AudioPacket {
    pub data: Vec<u8>,
    pub id: String
}

static RECEIVE_SENDER: Lazy<Mutex<Sender<AudioPacket>>> = Lazy::new(|| {
    let (sender, _) = mpsc::channel();
    Mutex::new(sender)
});

static RECEIVE_RECEIVER: Lazy<Mutex<Receiver<AudioPacket>>> = Lazy::new(|| {
    let (_, receiver) = mpsc::channel();
    Mutex::new(receiver)
});

pub fn send_packet(packet: AudioPacket) {
    RECEIVE_SENDER.lock().expect("channel kaputt").send(packet).expect("sending kaputt");
}

struct DecoderInfo {
    pub decoder: coder::Decoder,
    pub protocol: Protocol,
}

// Starts a thread that decodes and plays the audio
pub fn decode_play_thread() {

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

        logger::send_log(logger::TAG_AUDIO, format!("Output device: {}", device.name().unwrap()).as_str());
        let (mut _stream, mut stream_handle) = OutputStream::try_from_device(&device).expect("Couldn't start output stream");
        let mut sink = Sink::try_new(&stream_handle).expect("Couldn't create sink");
        let mut decoders: HashMap<String, DecoderInfo> = HashMap::new();
        let mut talking: HashMap<String, SystemTime> = HashMap::new();
        //let mut last_packet = SystemTime::now();

        loop {

            if super::get_output_device() != last_value {
                for d in host.output_devices().expect("Couldn't get output devices") {
                    if d.name().unwrap() == super::get_output_device() {
                        device = d;
                        break;
                    }
                }
                logger::send_log(logger::TAG_AUDIO, format!("Output device changed to: {}", device.name().unwrap()).as_str());
                drop(_stream);
                last_value = super::get_output_device();
                (_stream, stream_handle) = OutputStream::try_from_device(&device).expect("Couldn't start output stream");
                sink = Sink::try_new(&stream_handle).expect("Couldn't create sink");
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
                util::send_action(api::Action {
                    action: super::ACTION_STOPPED_TALKING.to_string(),
                    data: key.clone(),
                });
                talking.remove(&key);
            }

            let packet_result = match RECEIVE_RECEIVER.lock() {
                Ok(receiver) => receiver,
                Err(receiver) => receiver.into_inner(),
            }.recv_timeout(Duration::from_millis(100));
            if packet_result.is_err() {
                continue;
            }
            let packet = packet_result.unwrap();
            let (protocol, voice_data) = packet.data.split_at(2);
            let prefix = String::from_utf8(protocol.to_vec()).unwrap();

            // Decode (if decoder available)
            let protocol_option = connection::protocol_from_prefix(prefix.as_str());
            if protocol_option == None {
                continue;
            }
            let protocol = protocol_option.unwrap();
            let item = decoders.entry(packet.id.clone()).or_insert_with(|| {
                DecoderInfo {
                    decoder: coder::Decoder::new(protocol.opus_sample_rate(), audiopus::Channels::Mono).unwrap(),
                    protocol: protocol.clone(),
                }
            });
            if item.protocol != protocol {
                decoders.remove(&packet.id);
                continue;
            }
            let prev = talking.insert(packet.id.clone(), SystemTime::now());
            if prev == None {
                util::send_action(api::Action{
                    action: super::ACTION_STARTED_TALKING.to_string(),
                    data: packet.id.clone(),
                });
            }
            let decoded = decode(voice_data, audio::encode::FRAME_SIZE, &mut item.decoder);

            //logger::send_log(logger::TAG_AUDIO, format!("delay {}ns", SystemTime::now().duration_since(last_packet).unwrap().as_nanos()).as_str());
            //last_packet = SystemTime::now();
            sink.append(SamplesBuffer::new(1, protocol.opus_sample_rate() as u32, decoded));
        }
    });
}