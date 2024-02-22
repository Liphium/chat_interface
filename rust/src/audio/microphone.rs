use std::{
    sync::{Arc, Mutex},
    thread,
    time::Duration,
};

use cpal::{
    traits::{DeviceTrait, HostTrait, StreamTrait},
    StreamConfig,
};
use rubato::{FftFixedOut, Resampler};

use crate::{audio::encode, connection, logger};

pub fn record(conn_config: Arc<connection::Config>) {
    thread::spawn(move || {
        // Get a cpal host
        let mut host = cpal::default_host(); // Current host on computer
        #[cfg(target_os = "linux")]
        {
            host = cpal::host_from_id(cpal::HostId::Jack).unwrap();
        }

        // Get input device (using new API)
        let mut device = host
            .default_input_device()
            .expect("no input device available"); // Current device
        for d in host.input_devices().expect("Couldn't get input devices") {
            if d.name().unwrap() == super::get_input_device() {
                device = d;
                break;
            }
        }
        let last_value = super::get_input_device();

        // Create a stream config
        let default_config = device
            .default_input_config()
            .expect("no stream config found");
        logger::send_log(
            logger::TAG_AUDIO,
            format!("default config: {:?}", default_config).as_str(),
        );
        let sample_rate: u32 = default_config.sample_rate().0;
        let work_channels = 1; // Stereo doesn't work at the moment (will fix in the future or never)
        let mic_channels = default_config.channels();
        connection::new_protocol(connection::nearest_opus_protocol(
            default_config.sample_rate().0,
        ));

        let config: StreamConfig = StreamConfig {
            channels: mic_channels,
            sample_rate: cpal::SampleRate(sample_rate),
            buffer_size: cpal::BufferSize::Fixed(4096),
        };

        // Create a resampler
        let mut resampler = FftFixedOut::<f64>::new(
            sample_rate as usize,
            connection::get_protocol().usize(),
            encode::FRAME_SIZE,
            encode::FRAME_SIZE,
            work_channels as usize,
        )
        .unwrap();

        // Create buffer for overflowing samplesd
        let overflow_buffer = Arc::new(Mutex::new(Vec::<f32>::new()));
        let overflow_buffer_2: Arc<Mutex<Vec<f32>>> = overflow_buffer.clone();

        // Start listening for data to encode in another thread
        encode::encode_thread(conn_config.clone(), (work_channels as usize).clone());

        // Create a stream
        let cloned_config = conn_config.clone();
        let stream = match device.build_input_stream(
            &config.into(),
            move |data: &[f32], _: &_| {
                resample_data(data, &mut resampler, &overflow_buffer_2, mic_channels);
            },
            move |err| {
                logger::send_log(
                    logger::TAG_ERROR,
                    format!("an error occurred on stream: {}", err).as_str(),
                );
            },
            None,
        ) {
            Ok(stream) => stream,
            Err(err) => {
                logger::send_log(
                    logger::TAG_ERROR,
                    format!("an error occurred on stream: {}", err).as_str(),
                );
                return;
            }
        };

        // Play the stream
        stream.play().unwrap();

        loop {
            if last_value != super::get_input_device() {
                logger::send_log(
                    logger::TAG_AUDIO,
                    format!(
                        "Input device changed to {}, restarting",
                        super::get_input_device()
                    )
                    .as_str(),
                );
                record(cloned_config);
                break;
            }

            if connection::should_stop() {
                break;
            }
            thread::sleep(Duration::from_millis(100));
        }
    });
}

// From copilot chat
fn stereo_to_mono(pcm: &[f32]) -> Vec<f32> {
    let mut mono = Vec::with_capacity(pcm.len() / 2);
    for i in (0..pcm.len()).step_by(2) {
        let left = pcm[i];
        let right = pcm[i + 1];
        mono.push((left + right) * 0.5)
    }
    mono
}

fn resample_data(
    data: &[f32],
    resampler: &mut FftFixedOut<f64>,
    overflow_buffer_p: &Arc<Mutex<Vec<f32>>>,
    channels: u16,
) {
    // Cut down to needed size and add to overflow buffer (MONO ONLY)
    let mut max_length = resampler.input_frames_next();
    let mut overflow_buffer = overflow_buffer_p.lock().unwrap();

    if channels == 2 {
        overflow_buffer.extend_from_slice(&stereo_to_mono(data));
    } else {
        overflow_buffer.extend_from_slice(data);
    }

    while overflow_buffer.len() > max_length {
        // Get data to resample from overflow
        let buffer = if overflow_buffer.len() > max_length {
            let buffer = overflow_buffer.drain(0..max_length).collect::<Vec<f32>>();
            buffer
        } else {
            return;
        };

        // Extract channels
        let mut extracted_channels: Vec<Vec<f64>> =
            vec![Vec::<f64>::with_capacity(buffer.len()); 1];
        extracted_channels[0] = buffer.iter().map(|&x| x as f64).collect::<Vec<f64>>();

        // Resample and reverse extract
        let resampled = resampler.process(&extracted_channels, None).unwrap();
        let sample = resampled[0].iter().map(|&x| x as f32).collect::<Vec<f32>>();

        // Add all to sample_vec
        encode::pass_to_encode(sample);

        // Prepare for next iteration
        max_length = resampler.input_frames_next() * channels as usize;
    }
}

/* IN CASE WE EVER NEED STEREO AGAIN
fn extract_channels(data: &[f32], channels: usize) -> Vec<Vec<f64>> {

    let mut channels_data = vec![Vec::<f64>::with_capacity(data.len() / channels); channels];
    for (_, sample) in data.chunks(channels).enumerate() {
        channels_data[0].push(sample[0] as f64);
        if channels == 2 {
            channels_data[1].push(sample[1] as f64);
        }
    }
    channels_data
} */

/* IN CASE WE EVER NEED STEREO AGAIN
fn reverse_extract_channels(channels_data: &[Vec<f64>]) -> Vec<f32> {
    let channel_size = channels_data.len();
    let num_samples = channels_data[0].len();
    let mut interleaved_samples = Vec::with_capacity(num_samples * channel_size);
    for i in 0..num_samples {
        for j in 0..channel_size {
            interleaved_samples.push(channels_data[j][i] as f32);
        }
    }
    interleaved_samples
} */
