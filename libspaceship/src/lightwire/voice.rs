use std::{sync::Arc, thread, time::Duration};

use cpal::traits::{HostTrait, StreamTrait};
use rodio::DeviceTrait;
use rubato::{FftFixedOut, Resampler};
use tokio::sync::{
    mpsc::{self, Receiver, Sender},
    Mutex,
};

use crate::{error, info};

use super::get_preferred_host;

pub struct VoiceInput {
    device: String,
    sample_rate: u32,
    frame_size: u32,
    stop: bool,
    paused: bool,
}

impl VoiceInput {
    pub fn create() -> (Arc<Mutex<Self>>, Receiver<Vec<f32>>) {
        let voice_input = Arc::new(Mutex::new(Self {
            device: "def".to_string(),
            sample_rate: 48000,
            frame_size: 48000 / 50,
            stop: false,
            paused: true,
        }));

        // Create a new channel for sending the packets
        let (sender, receiver) = mpsc::channel(4);

        // Create a new task for handling all of the sending
        VoiceInput::create_task(voice_input.clone(), sender);

        return (voice_input, receiver);
    }

    // Create the blocking task for the actual recording of the microphone
    fn create_task(voice_input: Arc<Mutex<VoiceInput>>, sender: Sender<Vec<f32>>) {
        tokio::task::spawn_blocking({
            let sender = sender;
            let vc_input = voice_input.clone(); // Clone for use in the task
            move || {
                // Create the stream here to make sure it stays in scope
                let host = get_preferred_host();

                // Get the currently selected device
                let mut device = host
                    .default_input_device()
                    .expect("No default input device");
                let selected_device = {
                    let input = vc_input.blocking_lock();
                    input.device.clone()
                };
                for dev in host.input_devices().expect("Couldn't get input devices") {
                    if dev.name().expect("Couldn't get device name") == selected_device {
                        device = dev;
                        break;
                    }
                }

                // Create stream config for the device based on the channels
                // Determine appropriate buffer size based on device capabilities
                let device_config = device.default_input_config().expect("No default config");
                let channels = device_config.channels();
                let frame_size = {
                    let input = vc_input.blocking_lock();
                    input.frame_size
                };
                let desired_buffer_size = match device_config.buffer_size() {
                    cpal::SupportedBufferSize::Range { min, max } => {
                        // Try to use frame_size, but stay within allowed range
                        let frame_size = frame_size * channels as u32;
                        cpal::BufferSize::Fixed(frame_size.clamp(*min, *max))
                    }
                    cpal::SupportedBufferSize::Unknown => {
                        // Use default buffer size when unknown
                        cpal::BufferSize::Default
                    }
                };
                let stream_config = cpal::StreamConfig {
                    channels: device_config.channels(),
                    sample_rate: device_config.sample_rate(),
                    buffer_size: desired_buffer_size,
                };

                // Create a resampler to resample to 48kHz (default sample rate)
                let sample_rate = {
                    let input = vc_input.blocking_lock();
                    input.sample_rate
                };
                let mut resampler = FftFixedOut::<f32>::new(
                    usize::try_from(device_config.sample_rate().0).unwrap(),
                    usize::try_from(sample_rate).unwrap(),
                    usize::try_from(frame_size).unwrap(),
                    1,
                    1,
                )
                .expect("Couldn't create resampler");

                // Error function for printing errors that happen during voice handling
                let err_fn = move |err| error!("error in cpal: {}", err);

                // Create the callback for the voice data received from cpal
                let callback = {
                    let input: Arc<Mutex<VoiceInput>> = vc_input.clone();
                    let mut overflow_buffer = Vec::<f32>::new();
                    let sender = sender.to_owned();
                    let dev = selected_device.clone();

                    move |data: &[f32], _: &cpal::InputCallbackInfo| {
                        // Check if paused
                        {
                            let input = input.blocking_lock();
                            if input.paused {
                                return;
                            }
                        }

                        println!("sending.. {}", dev);

                        // Add the data to the buffer
                        if channels == 1 {
                            overflow_buffer.extend_from_slice(data);
                        } else {
                            // Convert to mono from stereo
                            let mono: Vec<f32> =
                                data.chunks(2).map(|c| (c[0] + c[1]) * 0.5).collect();
                            overflow_buffer.extend_from_slice(&mono);
                        }

                        // Get the frame size needed for resampling
                        let mut needed_frame_size = resampler.input_frames_next();

                        // Dispatch complete frames
                        while overflow_buffer.len() >= needed_frame_size {
                            let packet: Vec<f32> = overflow_buffer
                                .drain(0..needed_frame_size as usize)
                                .collect();

                            // Resample the packet
                            let result = resampler
                                .process(&[packet], None)
                                .expect("Couldn't resample");

                            // Send the packet
                            sender.blocking_send(result[0].to_owned()).ok();

                            // Set the next frame size
                            needed_frame_size = resampler.input_frames_next();
                        }
                    }
                };

                // Start the audio listening stream
                let stream = device
                    .build_input_stream(&stream_config, callback, err_fn, None)
                    .expect("Couldn't build stream");

                stream.play().expect("Couldn't start stream");

                loop {
                    // Check if there was a new device or if the thing was stopped
                    let new_device = {
                        let input = vc_input.blocking_lock();
                        if input.stop {
                            break;
                        }
                        input.device != selected_device
                    };

                    // Restart in that case
                    if new_device {
                        info!("new device");
                        VoiceInput::create_task(vc_input.clone(), sender.clone());
                        break;
                    }

                    thread::sleep(Duration::from_millis(100));
                }
            }
        });
    }

    pub fn set_paused(&mut self, paused: bool) {
        self.paused = paused;
    }

    pub fn stop(&mut self) {
        self.stop = true;
    }

    pub fn set_device(&mut self, device: String) {
        self.device = device
    }
}
