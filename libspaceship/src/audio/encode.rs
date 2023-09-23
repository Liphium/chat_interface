use std::{thread, sync::{Mutex, mpsc::{Sender, Receiver, self}, Arc}};

use once_cell::sync::Lazy;
use crate::{audio, util, logger};

use crate::connection;

use super::decode;

pub const SAMPLE_RATE: audiopus::SampleRate = audiopus::SampleRate::Hz48000;
pub const FRAME_SIZE: usize = 960;

pub fn encode(samples: Vec<f32>, encoder: &mut audiopus::coder::Encoder) -> Vec<u8> {

    let mut output: Vec<u8> = vec![0u8; 3000];

    return match encoder.encode_float(&samples, &mut output) {
        Ok(size) => {
            output.split_at(size).0.to_vec()
        },
        Err(err) => panic!("error encoding: {}", err)
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
    ENCODE_SENDER.lock().expect("channel kaputt").send(data).expect("sending kaputt");
}

pub fn encode_thread(config: Arc<connection::Config>, channels: usize) {

    // Encode channel
    let (sender, receiver) = mpsc::channel();
    let mut actual_sender = ENCODE_SENDER.lock().unwrap();
    *actual_sender = sender;
    let mut actual_receiver = ENCODE_RECEIVER.lock().unwrap();
    *actual_receiver = receiver;

    let opus_channel = match channels {
        1 => audiopus::Channels::Mono,
        2 => audiopus::Channels::Stereo,
        _ => panic!("invalid channel count")
    };

    // Spawn a thread
    thread::spawn(move || {

        // Create encoder
        let mut encoder = audiopus::coder::Encoder::new(SAMPLE_RATE, opus_channel, audiopus::Application::Voip).unwrap();
        let mut buffer = Vec::<u8>::with_capacity(8000);
        let mut talking_streak = 0;

        // Set the bitrate to 128 kb/s
        encoder.set_bitrate(audiopus::Bitrate::BitsPerSecond(128000)).unwrap();

        loop {

            if connection::should_stop() {
                return;
            }

            let samples = ENCODE_RECEIVER.lock().unwrap().recv().expect("Encoding channel broke");
            let samples_len = samples.len();

            if samples_len < FRAME_SIZE * channels {
                continue;
            }

            let mut options = audio::AUDIO_OPTIONS.lock().unwrap();

            let mut max = 0.0;
            for sample in samples.iter() {
                if *sample > max {
                    max = *sample;
                }
            }

            if options.amplitude_logging {
                logger::send_log(logger::TAG_CODEC, &format!("max:{}", max));
            }

            if max > options.talking_amplitude {
                talking_streak = 10;

                if !options.talking {
                    util::print_action("started_talking");
                }
                options.talking = true;
            } else if talking_streak <= 0 {

                if options.talking {
                    util::print_action("stopped_talking");
                }
                options.talking = false;
            } else {
                talking_streak -= 1;
            }

            if config.test { // TODO: Test thing

                if options.talking {
                    let encoded = encode(samples, &mut encoder);
                    decode::pass_to_decode(encoded);
                }

            } else if config.connection && !options.muted && !options.silent_mute && options.talking {
                logger::send_log(logger::TAG_CODEC, "sending audio");
                let encoded = encode(samples, &mut encoder);
                connection::construct_packet(&config, &encoded, &mut buffer);
                logger::send_log(logger::TAG_CODEC, format!("packet len: {}", buffer.len()).as_str());

                //decode::pass_to_decode(encoded);

                //connection::udp::send(buffer);

                /*
                let mut channel = vec![b'v', b':'];
                channel.append(&mut encoded);    
                connection::udp::send(auth::encrypted_packet(&mut channel)); */
            }
        }
    });
}