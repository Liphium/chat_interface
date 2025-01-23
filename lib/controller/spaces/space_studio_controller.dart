import 'package:chat_interface/services/spaces/studio/space_studio_connection.dart';
import 'package:chat_interface/services/spaces/studio/space_studio_service.dart';

class SpaceStudioController {
  static StudioConnection? _connection;

  /// Connect to Studio.
  ///
  /// Returns an error if there was one.
  static Future<String?> connectToStudio() async {
    // Connect to Studio using the service
    final (connection, error) = await SpaceStudioService.connectToStudio();
    if (error != null) {
      return error;
    }

    _connection = connection;
    return null;
  }

  static void resetControllerState() {
    _connection = null;
  }
}
