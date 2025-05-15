use std::{collections::HashMap, sync::Arc, thread, time::Duration};

use audiopus::coder::Decoder;
use cpal::{traits::HostTrait, Device};
use jittr::JitterBuffer;
use rodio::{buffer::SamplesBuffer, DeviceTrait, OutputStream, OutputStreamHandle, Sink};
use tokio::{
    sync::{
        mpsc::{self, UnboundedSender},
        Mutex,
    },
    time,
};

use crate::binding::{error, info};

use super::{get_preferred_host, AudioPacket};

pub struct PlayingEngine {
    client_map: HashMap<String, Arc<Mutex<Client>>>,
    device: String,
    output_handle: Option<OutputStreamHandle>,
    enabled: bool,
    stop: bool,
}

struct Client {
    sink: Sink,
    buffer: JitterBuffer<AudioPacket, 8>,
    decoder: Option<Decoder>,
}

// Default sample rate for all packets
static DEFAULT_SAMPLE_RATE: u32 = 48000;
static DEFAULT_FRAME_SIZE: usize = (DEFAULT_SAMPLE_RATE / 50) as usize;
static DEFAULT_SAMPLE_RATE_OPUS: audiopus::SampleRate = audiopus::SampleRate::Hz48000;

impl PlayingEngine {
    pub async fn create() -> (Arc<Mutex<PlayingEngine>>, UnboundedSender<AudioPacket>) {
        let engine = Arc::new(Mutex::new(Self {
            client_map: HashMap::new(),
            device: "-".to_string(),
            output_handle: None,
            enabled: true,
            stop: false,
        }));

        // Create a new channel for the packets coming in
        let (sender, mut receiver) = mpsc::unbounded_channel();

        tokio::task::spawn_blocking({
            let engine = engine.clone();
            move || {
                // Stream needs to be created on the main thread
                let (mut _stream, mut stream_handle): (OutputStream, OutputStreamHandle);

                // Start a loop to keep the stream in scope until the engine exists
                let mut last_device = "----".to_string();
                loop {
                    {
                        let mut engine = engine.blocking_lock();
                        if engine.stop {
                            info("stopping playing engine");
                            return;
                        }

                        // Restart the output stream when the device changes
                        if engine.device != last_device {
                            let host = get_preferred_host();

                            // Try to get the device
                            let mut device: Option<Device> = None;
                            for dev in host.output_devices().expect("Couldn't list output devices")
                            {
                                if dev.name().expect("Couldn't get output name") == engine.device {
                                    device = Some(dev);
                                    break;
                                }
                            }

                            // Create the new output stream
                            if let Some(dev) = device {
                                (_stream, stream_handle) = OutputStream::try_from_device(&dev)
                                    .expect("Failed to get output stream from found device");
                            } else {
                                (_stream, stream_handle) = OutputStream::try_default()
                                    .expect("Failed to get default output stream");
                            }
                            engine.output_handle = Some(stream_handle);

                            // Change the sinks of all the clients to use the the new output stream
                            for client in engine.client_map.values() {
                                let mut client = client.blocking_lock();
                                client.sink = Sink::try_new(engine.output_handle.as_ref().unwrap())
                                    .expect("Couldn't create new Sink")
                            }

                            last_device = engine.device.clone();
                        }
                    }
                    thread::sleep(Duration::from_millis(500));
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
                    let engine = engine.lock().await;
                    let data = data.unwrap();
                    if data.is_none() || engine.stop {
                        info("closed playing engine");
                        return;
                    }
                    let data: AudioPacket = data.expect("No data found");

                    // Make sure the client with the specified id actually exists
                    let client_id = data
                        .id
                        .as_ref()
                        .expect("No client id in packet for decoding, can't decode this");
                    if !engine.client_map.contains_key(client_id) {
                        error(format!("client {} hasn't been added yet", client_id));
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
    pub fn add_target(&mut self, arc: Arc<Mutex<PlayingEngine>>, id: String) {
        // Create a sink for the thing
        let handle = self.output_handle.as_ref().unwrap();
        let sink = Sink::try_new(handle).expect("Couldn't create sink");

        // Add the target to the playing engine
        let client = Arc::new(Mutex::new(Client {
            sink: sink,
            buffer: JitterBuffer::new(),
            decoder: None,
        }));
        self.client_map.insert(id.clone(), client.clone());

        // Spawn a task for playing the packets at a consistent interval
        tokio::spawn(async move {
            let mut seals = 0;
            let mut interval = time::interval(Duration::from_millis(20));
            loop {
                interval.tick().await;
                let mut engine = arc.lock().await; // needs to be locked here to prevent deadlocks with device switching
                let mut client = client.lock().await;

                // Make sure the engine is actually enabled
                if !engine.enabled {
                    engine.remove_target(&id);
                    info(format!("unused listener for client {}", id));
                    client.buffer.clear();
                    return;
                }

                // Shutdown the listener completely at some point to prevent unneeded resource usage
                seals += 1;
                if seals > 1000 {
                    engine.remove_target(&id);
                    info(format!("unused listener for client {}", id));
                    client.buffer.clear();
                    return;
                }

                // Actually play the packet (or add seal)
                if let Some(packet) = client.buffer.pop() {
                    seals = 0;

                    // Create a decoder in case there isn't one
                    if client.decoder.is_none() {
                        client.decoder = Some(
                            Decoder::new(DEFAULT_SAMPLE_RATE_OPUS, audiopus::Channels::Mono)
                                .expect("Couldn't create decoder"),
                        );
                    }

                    // Decode the packet
                    let decoder = client.decoder.as_mut().expect("Decoder not found, wtf");
                    let mut decoded = [0f32; DEFAULT_FRAME_SIZE];
                    let frame_size = decoder
                        .decode_float(Some(&packet.packet.unwrap()), &mut decoded[..], false)
                        .expect("Couldn't decode packet");
                    let (decoded, _) = decoded.split_at(frame_size);

                    println!("playing seq={}", packet.seq);

                    // Play the packet using the sink
                    client
                        .sink
                        .append(SamplesBuffer::new(1, DEFAULT_SAMPLE_RATE, decoded));
                } else if let Some(decoder) = &mut client.decoder {
                    // Don't generate seals anymore at some point
                    if seals > 10 {
                        continue;
                    }

                    // Generate loss concealment using the decoder
                    let mut decoded = [0f32; DEFAULT_FRAME_SIZE];
                    let none_option: Option<&Vec<u8>> = None;
                    let frame_size = decoder
                        .decode_float(none_option, &mut decoded[..], false)
                        .expect("Couldn't generate loss concealment");
                    let (decoded, _) = decoded.split_at(frame_size);

                    // Play the loss concealment using the sink
                    client
                        .sink
                        .append(SamplesBuffer::new(1, DEFAULT_SAMPLE_RATE, decoded));
                }
            }
        });
    }

    // Remove a target from the engine
    pub fn remove_target(&mut self, id: &String) {
        self.client_map.remove(id);
    }

    // Completely stop the engine
    pub fn stop(&mut self) {
        self.stop = true;
        self.client_map.clear();
    }

    // Enable or disable playing sound
    pub fn set_enabled(&mut self, enabled: bool) {
        self.enabled = enabled;
    }

    // Get the enabled state of the engine
    pub fn is_enabled(&self) -> bool {
        self.enabled
    }

    // Set the output device of the engine
    pub fn set_device(&mut self, device: String) {
        self.device = device;
    }
}
