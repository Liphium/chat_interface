import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_message_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';

void setupSpaceMessageListeners() {
  // Listen for deletions
  spaceConnector.listen("msg", (event) async {
    // Make sure we're actually in a space right now
    if (!Get.find<SpacesController>().inSpace.value || SpacesController.key == null) {
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
    Get.find<SpacesMessageController>().addMessage(message);
  });
}
