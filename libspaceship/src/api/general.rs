use crate::{binding, frb_generated::StreamSink};

// Create a log stream that sends logs to Dart
pub async fn create_log_stream(sink: StreamSink<String>) {
    binding::set_log_sink(sink).await;
}
