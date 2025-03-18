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
    packet_sink: StreamSink<(Vec<u8>, bool)>,
) {
    binding::init_engine(engine.id, move |(packet, speech)| {
        packet_sink
            .add((packet, speech))
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
