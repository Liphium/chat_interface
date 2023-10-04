use std::{thread, sync::{Mutex, mpsc::{Sender, self, Receiver}}, collections::HashMap};

use audiopus::coder;
use once_cell::sync::Lazy;
use rodio::{Sink, OutputStream, buffer::SamplesBuffer};

use crate::{audio, logger, connection};

use super::encode;

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

// Starts a thread that decodes and plays the audio
pub fn decode_play_thread() {

    // Receive channel
    let (sender, receiver) = mpsc::channel();
    let mut actual_sender = RECEIVE_SENDER.lock().unwrap();
    *actual_sender = sender;
    let mut actual_receiver = RECEIVE_RECEIVER.lock().unwrap();
    *actual_receiver = receiver;

    thread::spawn(move || {

        let (_stream, stream_handle) = OutputStream::try_default().unwrap();
        let sink = Sink::try_new(&stream_handle).unwrap();
        let mut decoders: HashMap<String, coder::Decoder> = HashMap::<String, coder::Decoder>::new();

        loop {
            let packet = RECEIVE_RECEIVER.lock().unwrap().recv().expect("Decoding channel broke");
            let (protocol, voice_data) = packet.data.split_at(2);
            let prefix = String::from_utf8(protocol.to_vec()).unwrap();

            // Decode (if decoder available)
            let item = decoders.entry(packet.id).or_insert_with(|| {
                coder::Decoder::new(connection::protocol_from_prefix(prefix.as_str()).opus_sample_rate(), audiopus::Channels::Mono).unwrap()
            });
            let decoded = decode(voice_data, audio::encode::FRAME_SIZE, item);

            logger::send_log(logger::TAG_AUDIO, format!("Decoded {} samples", decoded.len()).as_str());
            sink.append(SamplesBuffer::new(1, encode::SAMPLE_RATE as u32, decoded));
        }
    });
}