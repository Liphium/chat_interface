import 'package:chat_interface/services/spaces/studio/studio_connection.dart';
import 'package:chat_interface/services/spaces/studio/studio_service.dart';
import 'package:signals/signals_flutter.dart';

class StudioController {
  static StudioConnection? _connection;

  // State for the UI
  static final connecting = signal(false);
  static final connectionError = signal("");
  static final connected = signal(false);

  // Media controls
  static final videoEnabled = signal(false);

  /// Connect to Studio.
  ///
  /// Returns an error if there was one.
  static Future<void> connectToStudio() async {
    connecting.value = true;

    // Connect to Studio using the service
    final (connection, error) = await StudioService.connectToStudio();
    if (error != null) {
      batch(() {
        connectionError.value = error;
        connecting.value = false;
      });
      return;
    }

    // Set all the state
    _connection = connection;
    batch(() {
      connecting.value = false;
      connected.value = true;
    });
  }

  static void resetControllerState() {
    _connection?.close();
    _connection = null;
    connected.value = false;
    connecting.value = false;
    videoEnabled.value = false;
  }

  /// Called by the service when Studio gets disconnected.
  static void handleDisconnect() {
    resetControllerState();
  }

  /// Get the connection to Studio.
  ///
  /// Should only be accessed by services.
  static StudioConnection? getConnection() {
    return _connection;
  }
}
