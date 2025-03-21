use std::{collections::HashMap, sync::Arc, thread, time::Duration};

use audiopus::coder::Decoder;
use jittr::JitterBuffer;
use rodio::{buffer::SamplesBuffer, OutputStream, OutputStreamHandle, Sink};
use tokio::{
    sync::{
        mpsc::{self, UnboundedSender},
        Mutex,
    },
    time,
};

use crate::{error, info};

use super::AudioPacket;

pub struct PlayingEngine {
    client_map: HashMap<String, Arc<Mutex<Client>>>,
    output_handle: Option<OutputStreamHandle>,
    stop: bool,
}

struct Client {
    sink: Sink,
    buffer: JitterBuffer<AudioPacket, 8>,
    decoder: Option<Decoder>,
}

// Default sample rate for all packets
static DEFAULT_SAMPLE_RATE: u32 = 48000;
static DEFAULT_SAMPLE_RATE_OPUS: audiopus::SampleRate = audiopus::SampleRate::Hz48000;

impl PlayingEngine {
    pub async fn create() -> (Arc<Mutex<PlayingEngine>>, UnboundedSender<AudioPacket>) {
        let engine = Arc::new(Mutex::new(Self {
            client_map: HashMap::new(),
            output_handle: None,
            stop: false,
        }));

        // Create a new channel for the packets coming in
        let (sender, mut receiver) = mpsc::unbounded_channel();

        tokio::task::spawn_blocking({
            let engine = engine.clone();
            move || {
                // Stream needs to be created on the main thread
                let (_stream, stream_handle) =
                    OutputStream::try_default().expect("Failed to get default output stream");
                {
                    let mut engine_lock = engine.blocking_lock();
                    engine_lock.output_handle = Some(stream_handle);
                }

                // Start a loop to keep the stream in scope until the engine exists
                loop {
                    thread::sleep(Duration::from_millis(500));
                    let engine = engine.blocking_lock();
                    if engine.stop {
                        return;
                    }
                }
            }
        });

        tokio::spawn({
            let engine = engine.clone();
            async move {
                loop {
                    // Listen for new audio packets
                    let data = time::timeout(Duration::from_millis(500), receiver.recv()).await;
                    if data.is_err() {
                        continue;
                    }
                    let data = data.unwrap();
                    if data.is_none() {
                        info!("closed playing engine.");
                        return;
                    }
                    let data: AudioPacket = data.expect("No data found");

                    // Make sure the client with the specified id actually exists
                    let engine = engine.lock().await;
                    let client_id = data
                        .id
                        .as_ref()
                        .expect("No client id in packet for decoding, can't decode this");
                    if !engine.client_map.contains_key(client_id) {
                        error!("client {} hasn't been added yet", client_id);
                        continue;
                    }

                    // Add the packet to the jitter buffer of the client
                    let client = engine
                        .client_map
                        .get(client_id)
                        .expect("Not found even though key exists, wtf");
                    let mut client = client.lock().await;
                    client.buffer.push(data);
                }
            }
        });

        return (engine, sender);
    }

    // Check if a target exists in the playing engine
    pub fn does_target_exist(&self, id: &String) -> bool {
        self.client_map.contains_key(id)
    }

    // Add a new client to the playing engine
    pub fn add_target(&mut self, id: String) {
        // Create a sink for the thing
        let handle = self.output_handle.as_ref().unwrap();
        let sink = Sink::try_new(&handle).expect("Couldn't create sink");

        // Add the target to the playing engine
        let client = Arc::new(Mutex::new(Client {
            sink: sink,
            buffer: JitterBuffer::new(),
            decoder: None,
        }));
        self.client_map.insert(id, client.clone());

        // Spawn a task for playing the packets at a consistent interval
        tokio::spawn(async move {
            let mut interval = time::interval(Duration::from_millis(20));
            loop {
                interval.tick().await;

                let mut client = client.lock().await;
                if let Some(packet) = client.buffer.pop() {
                    // Create a decoder in case there isn't one
                    if client.decoder.is_none() {
                        client.decoder = Some(
                            Decoder::new(DEFAULT_SAMPLE_RATE_OPUS, audiopus::Channels::Mono)
                                .expect("Couldn't create decoder"),
                        );
                    }

                    info!("packet received, seq={}", packet.seq);

                    // Decode the packet
                    let decoder = client.decoder.as_mut().expect("Decoder not found, wtf");
                    let mut decoded = [0f32; 2000];
                    let frame_size = decoder
                        .decode_float(Some(&packet.packet), &mut decoded[..], false)
                        .expect("Couldn't decode packet");
                    let (decoded, _) = decoded.split_at(frame_size);

                    // Play the packet using the sink
                    client
                        .sink
                        .append(SamplesBuffer::new(1, DEFAULT_SAMPLE_RATE, decoded));
                } else if let Some(decoder) = &mut client.decoder {
                    // Generate loss concealment using the decoder
                    let mut decoded = [0f32; 2000];
                    let none_option: Option<&Vec<u8>> = None;
                    let frame_size = decoder
                        .decode_float(none_option, &mut decoded[..], false)
                        .expect("Couldn't generate loss concealment");
                    let (decoded, _) = decoded.split_at(frame_size);

                    info!("packet missing, adding seal");

                    // Play the loss concealment using the sink
                    client
                        .sink
                        .append(SamplesBuffer::new(1, DEFAULT_SAMPLE_RATE, decoded));
                } else {
                    info!("packet missing, no seal");
                }
            }
        });
    }

    pub fn stop(&mut self) {
        self.stop = true;
    }
}
