use std::sync::Arc;

use encoder::EncodingEngine;
use player::PlayingEngine;
use tokio::sync::{mpsc::UnboundedSender, Mutex};
use voice::VoiceInput;

mod encoder;
mod player;
mod voice;

#[derive(Clone)]
pub struct Engine {
    voice_input: Arc<Mutex<VoiceInput>>,
    encoding_engine: Arc<Mutex<EncodingEngine>>,
    playing_engine: Arc<Mutex<PlayingEngine>>,
    packet_sender: UnboundedSender<AudioPacket>,
}

impl Engine {
    pub async fn create<F>(send_fn: F) -> Self
    where
        F: FnMut(AudioPacket) + Send + 'static,
    {
        // Create the voice input
        let (voice_input, receiver) = VoiceInput::create();

        // Create the encoding engine
        let encoding_engine = EncodingEngine::create(receiver, send_fn);

        // Start the playing engine
        let (playing_engine, sender) = PlayingEngine::create().await;

        // Initialize the engine
        return Self {
            voice_input: voice_input,
            encoding_engine: encoding_engine,
            playing_engine: playing_engine,
            packet_sender: sender,
        };
    }

    // Enable or disable the microphone
    pub async fn set_voice_enabled(&self, enabled: bool) {
        let mut input = self.voice_input.lock().await;
        input.set_paused(!enabled);
    }

    // Register a new target in the playing engine
    pub async fn register_target(&self, id: String) {
        let mut engine = self.playing_engine.lock().await;
        engine.add_target(id);
    }

    // Handle a packet
    pub async fn handle_packet(&self, id: String, packet: Vec<u8>) {
        self.packet_sender
            .send(AudioPacket::decode(Some(id), packet))
            .ok();
    }
}

#[derive(Clone)]
pub struct AudioPacket {
    pub id: Option<String>,
    pub seq: u16,
    pub packet: Vec<u8>,
}

impl jittr::Packet for AudioPacket {
    fn sequence_number(&self) -> u16 {
        self.seq
    }
}

impl AudioPacket {
    // Encode the audio packet to bytes
    //
    // Format: | seq | sample_rate | voice_data |
    pub fn encode(&self) -> Vec<u8> {
        let mut packet_vec = Vec::with_capacity(2 + 4 + self.packet.len());
        packet_vec.extend_from_slice(&self.seq.to_le_bytes());
        packet_vec.extend(self.packet.iter());
        return packet_vec;
    }

    // Decode the audio packet
    //
    // Format: | seq | sample_rate | voice_data |
    pub fn decode(id: Option<String>, bytes: Vec<u8>) -> Self {
        let (seq_bytes, packet) = bytes.split_at(2);
        return Self {
            id: id,
            seq: u16::from_le_bytes([seq_bytes[0], seq_bytes[1]]),
            packet: packet.to_vec(),
        };
    }
}

// Get the host lightwire is going to use (mainly for making sure we can easily change it in the future in case needed)
pub fn get_preffered_host() -> cpal::Host {
    return cpal::default_host();
}

/*
Demo of voice input and the decoding engine (just here for maybe future idk)

tokio::task::spawn_blocking(move || {
    let mut decoder =
        opus::Decoder::new(48000, opus::Channels::Mono).expect("Couldn't create decoder");

    let (_stream, stream_handle) =
        OutputStream::try_default().expect("Failed to get default output stream");
    let sink = Sink::try_new(&stream_handle).expect("Failed to create sink");

    // Decode all the packets
    loop {
        // Listen for new packets
        let encoded_sample = encoded_receiver.blocking_recv();
        if encoded_sample.is_none() {
            break;
        }

        // Decode the packet
        let mut output = [0f32; 2000];
        let amount = decoder
            .decode_float(
                encoded_sample.unwrap().packet.as_slice(),
                &mut output,
                false,
            )
            .expect("Couldn't decode");
        println!("decoded {}", amount);
        let (sample, _) = output.split_at(amount);

        let source = SamplesBuffer::new(1, sample_rate, sample);
        sink.append(source);
    }

    sink.sleep_until_end();
});

thread::sleep(Duration::from_secs(3));
{
    let mut voice_input_ref = voice_input.lock().unwrap();
    voice_input_ref.stop();
}
thread::sleep(Duration::from_secs(6));

*/
