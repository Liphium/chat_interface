import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/services/spaces/space_message_provider.dart';
import 'package:chat_interface/util/logging_framework.dart';

class SpaceMessageService {
  static void setupSpaceMessageListeners(Connector connector) {
    // Listen for deletions
    connector.listen("msg", (event) async {
      // Make sure we're actually in a space right now
      if (!SpaceController.connected.value || SpaceController.key == null) {
        sendLog("WARNING: received space message even though not in space");
        return;
      }

      // Unpack the message in a different isolate (to prevent lag)
      final message = await SpacesMessageProvider.unpackMessageInIsolate(event.data["msg"]);

      // Check if there are too many attachments
      if (message.attachments.length > 5) {
        sendLog("WARNING: invalid message, more than 5 attachments");
        return;
      }

      // Tell the controller about the message
      SpaceController.addMessage(message);
    });
  }
}
