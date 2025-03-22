use std::{sync::Arc, thread, time::Duration};

use cpal::traits::{HostTrait, StreamTrait};
use rodio::DeviceTrait;
use rubato::{FftFixedOut, Resampler};
use tokio::sync::{
    mpsc::{self, Receiver},
    Mutex,
};

use crate::error;

pub struct VoiceInput {
    device: cpal::Device,
    channels: u16,
    sample_rate: u32,
    frame_size: u32,
    stop: bool,
    paused: bool,
}

impl VoiceInput {
    pub fn create() -> (Arc<Mutex<Self>>, Receiver<Vec<f32>>) {
        // Get the default microphone and stream config
        let host = cpal::default_host();
        let device = host
            .default_input_device()
            .expect("No default device found");
        let device_config: cpal::SupportedStreamConfig = device
            .default_input_config()
            .expect("Failed to get default input config");

        let input = Arc::new(Mutex::new(Self {
            device: device,
            channels: device_config.channels(),
            sample_rate: 48000,
            frame_size: 48000 / 50,
            stop: false,
            paused: true,
        }));

        // Create a new channel for sending the packets
        let (sender, receiver) = mpsc::channel(4);

        // Create a new task for handling all of the sending
        tokio::task::spawn_blocking({
            let input = input.clone(); // Clone for use in the task
            move || {
                // Create stream config for the device based on the channels
                // Determine appropriate buffer size based on device capabilities
                let desired_buffer_size = {
                    let input = input.blocking_lock();
                    match device_config.buffer_size() {
                        cpal::SupportedBufferSize::Range { min, max } => {
                            // Try to use frame_size, but stay within allowed range
                            let frame_size = input.frame_size * input.channels as u32;
                            cpal::BufferSize::Fixed(frame_size.clamp(*min, *max))
                        }
                        cpal::SupportedBufferSize::Unknown => {
                            // Use default buffer size when unknown
                            cpal::BufferSize::Default
                        }
                    }
                };
                let stream_config = cpal::StreamConfig {
                    channels: device_config.channels(),
                    sample_rate: device_config.sample_rate(),
                    buffer_size: desired_buffer_size,
                };

                // Create a resampler to resample to 48kHz (default sample rate)
                let mut resampler = {
                    let input = input.blocking_lock();
                    FftFixedOut::<f32>::new(
                        usize::try_from(device_config.sample_rate().0).unwrap(),
                        usize::try_from(input.sample_rate).unwrap(),
                        usize::try_from(input.frame_size).unwrap(),
                        1,
                        1,
                    )
                    .expect("Couldn't create resampler")
                };

                // Error function for printing errors that happen during voice handling
                let err_fn = move |err| error!("error in cpal: {}", err);

                // Process data if needed (e.g. convert stereo to mono)
                let channels = {
                    let input = input.blocking_lock();
                    input.channels
                };
                let callback = {
                    let input = input.clone();
                    let mut overflow_buffer = Vec::<f32>::new();

                    move |data: &[f32], _: &cpal::InputCallbackInfo| {
                        // Check if paused
                        {
                            let input = input.blocking_lock();
                            if input.paused {
                                return;
                            }
                        }

                        // Add the data to the buffer
                        if channels == 1 {
                            overflow_buffer.extend_from_slice(data);
                        } else {
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

                // Start the audio stream
                let stream = {
                    let input = input.blocking_lock();
                    input
                        .device
                        .build_input_stream(&stream_config, callback, err_fn, None)
                        .expect("Couldn't build stream")
                };

                stream.play().expect("Couldn't start stream");

                loop {
                    {
                        let input = input.blocking_lock();
                        if input.stop {
                            break;
                        }
                    }

                    thread::sleep(Duration::from_millis(100));
                }
            }
        });

        return (input, receiver);
    }

    pub fn set_paused(&mut self, paused: bool) {
        self.paused = paused;
    }

    pub fn stop(&mut self) {
        self.stop = true;
    }
}
