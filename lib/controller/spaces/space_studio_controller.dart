import 'package:chat_interface/services/spaces/studio/space_studio_connection.dart';
import 'package:chat_interface/services/spaces/studio/space_studio_service.dart';
import 'package:chat_interface/util/popups.dart';

class SpaceStudioController {
  static StudioConnection? _connection;

  /// Connect to Studio.
  ///
  /// Returns an error if there was one.
  static Future<void> connectToStudio() async {
    // Connect to Studio using the service
    final (connection, error) = await SpaceStudioService.connectToStudio();
    if (error != null) {
      showErrorPopup("error", error);
      return;
    }

    // Set all the state
    _connection = connection;
  }

  static void resetControllerState() {
    _connection = null;
  }

  /// Called by the service when Studio gets disconnected.
  static void handleDisconnect() {
    resetControllerState();
  }
}
