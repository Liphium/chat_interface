use crate::{binding, frb_generated::StreamSink};

pub struct LightwireEngine {
    pub id: u32,
}

// Create a new engine
pub async fn create_lightwire_engine() -> LightwireEngine {
    LightwireEngine {
        id: binding::create_engine().await,
    }
}

// Stream the packets of an engine to a sink
pub async fn start_packet_stream(
    engine: LightwireEngine,
    packet_sink: StreamSink<(Option<Vec<u8>>, Option<f32>, Option<bool>)>,
) {
    binding::init_engine(engine.id, move |(packet, amplitude, speech)| {
        packet_sink
            .add((packet, amplitude, speech))
            .expect("Couldn't send packet");
    })
    .await;
}

// Set the enabled status of the microphone on an engine
pub async fn set_voice_enabled(engine: LightwireEngine, enabled: bool) {
    let engine = binding::get_engine(engine.id)
        .await
        .expect("Engine hasn't been initialized yet");
    engine.set_voice_enabled(enabled).await;
}

// Set the current input device for an engine
pub async fn set_input_device(engine: LightwireEngine, device: String) {
    let engine = binding::get_engine(engine.id)
        .await
        .expect("Engine hasn't been initialized yet");
    engine.set_input_device(device).await;
}

// Set the enabled status of the audio on an engine
pub async fn set_audio_enabled(engine: LightwireEngine, enabled: bool) {
    let engine = binding::get_engine(engine.id)
        .await
        .expect("Engine hasn't been initialized yet");
    engine.set_audio_enabled(enabled).await;
}

// Set the current output device for an engine
pub async fn set_output_device(engine: LightwireEngine, device: String) {
    let engine = binding::get_engine(engine.id)
        .await
        .expect("Engine hasn't been initialized yet");
    engine.set_output_device(device).await;
}

// Enable or disable voice activity detection on an engine
pub async fn set_activity_detection(engine: LightwireEngine, enabled: bool) {
    let engine = binding::get_engine(engine.id)
        .await
        .expect("Engine hasn't been initialized yet");
    engine.set_activity_detection(enabled).await;
}

// Enable or disable automatic voice activity detection for an engine
pub async fn set_automatic_detection(engine: LightwireEngine, enabled: bool) {
    let engine = binding::get_engine(engine.id)
        .await
        .expect("Engine hasn't been initialized yet");
    engine.set_automatic_detection(enabled).await;
}

// Set the talking amplitude for an engine
pub async fn set_talking_amplitude(engine: LightwireEngine, amplitude: f32) {
    let engine = binding::get_engine(engine.id)
        .await
        .expect("Engine hasn't been initialized yet");
    engine.set_talking_amplitude(amplitude).await;
}

// Let the engine play a new audio packet (id needs to be registered before using register_target)
pub async fn handle_packet(engine: LightwireEngine, id: String, packet: Vec<u8>) {
    let engine = binding::get_engine(engine.id)
        .await
        .expect("Engine hasn't been initialized yet");
    engine.handle_packet(id, packet).await;
}

// Stop an engine
pub async fn stop_engine(engine: LightwireEngine) {
    let lw_engine = binding::get_engine(engine.id)
        .await
        .expect("Engine hasn't been initialized yet");
    lw_engine.stop().await;
    binding::delete_engine(engine.id).await;
}

// Stop all engines currently there
pub async fn stop_all_engines() {
    binding::stop_all_engines().await;
}
