use std::{thread, sync::{Mutex, mpsc::{Sender, self, Receiver}}};

use once_cell::sync::Lazy;
use rodio::{Sink, OutputStream, buffer::SamplesBuffer};

use crate::{audio, util};

use super::encode;

pub fn decode(samples: Vec<u8>, buffer_size: usize, decoder: &mut audiopus::coder::Decoder) -> Vec<f32> {

    let mut output: Vec<f32> = vec![0f32; buffer_size];

    return match decoder.decode_float(Some(&samples), &mut output, false) {
        Ok(size) => {
            output.split_at(size).0.to_vec()
        },
        Err(err) => panic!("error decoding: {}", err)
    };
}

static RECEIVE_SENDER: Lazy<Mutex<Sender<Vec<u8>>>> = Lazy::new(|| {
    let (sender, _) = mpsc::channel();
    Mutex::new(sender)
});

static RECEIVE_RECEIVER: Lazy<Mutex<Receiver<Vec<u8>>>> = Lazy::new(|| {
    let (_, receiver) = mpsc::channel();
    Mutex::new(receiver)
});

pub fn pass_to_decode(data: Vec<u8>) {
    RECEIVE_SENDER.lock().expect("channel kaputt").send(data).expect("sending kaputt");
}

// Starts a thread that decodes and plays the audio
pub fn decode_play_thread() {

    // Receive channel
    let (sender, receiver) = mpsc::channel();
    let mut actual_sender = RECEIVE_SENDER.lock().unwrap();
    *actual_sender = sender;
    let mut actual_receiver = RECEIVE_RECEIVER.lock().unwrap();
    *actual_receiver = receiver;

    // Create decoder
    let mut decoder = audiopus::coder::Decoder::new(audio::encode::SAMPLE_RATE, audiopus::Channels::Mono).unwrap();

    thread::spawn(move || {

        let (_stream, stream_handle) = OutputStream::try_default().unwrap();
        let sink = Sink::try_new(&stream_handle).unwrap();

        loop {
            let data = RECEIVE_RECEIVER.lock().unwrap().recv().expect("Decoding channel broke");
            let decoded = decode(data, audio::encode::FRAME_SIZE, &mut decoder);

            util::print_log("Decoded audio");

            sink.append(SamplesBuffer::new(1, encode::SAMPLE_RATE as u32, decoded));
        }
    });
}