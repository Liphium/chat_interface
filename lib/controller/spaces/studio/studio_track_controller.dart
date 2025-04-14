import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:signals/signals_flutter.dart';

class StudioTrackController {
  /// All the tracks published by the server.
  ///
  /// Updated in real time through the event stream.
  static final tracks = mapSignal(<String, StudioTrack>{});

  /// Update a track or register it if it's not there yet.
  static void updateOrRegisterTrack(StudioTrack track) {
    // If the track is already registed, update it.
    if (tracks[track.id] != null) {
      tracks[track.id]!.takeUpdate(
        paused: track.paused.peek(),
        channels: track.channels.peek(),
        subscribers: track.channels.peek(),
      );
      return;
    }

    sendLog("new track: ${track.id}");

    // Register as a new track
    tracks[track.id] = track;
  }

  /// Delete a track from the controller.
  static void deleteTrack(String id) {
    tracks.remove(id);
  }

  /// Reset all of the controller state (when the user disconnects from the Space)
  static void handleDisconnect() {
    tracks.clear();
  }
}

/// A track published by Studio.
class StudioTrack {
  final String id;
  final SpaceMember publisher;
  final paused = signal(false);
  final channels = listSignal(<String>[]);
  final subscribers = listSignal(<String>[]);

  StudioTrack({
    required this.id,
    required this.publisher,
    required bool paused,
    required List<String> channels,
    required List<String> subscribers,
  }) {
    this.paused.value = paused;
  }

  /// Update the track but only set what's needed.
  void takeUpdate({bool? paused, List<String>? channels, List<String>? subscribers}) {
    if (paused != null && this.paused.peek() != paused) {
      this.paused.value = paused;
    }
    if (channels != null && this.channels.peek() != channels) {
      this.channels.value = channels;
    }
    if (subscribers != null && this.subscribers.peek() != subscribers) {
      this.subscribers.value = subscribers;
    }
  }
}
