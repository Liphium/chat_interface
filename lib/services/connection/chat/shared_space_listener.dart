import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/square/shared_space_controller.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/services/squares/square_shared_space.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';

class SharedSpaceListener {
  static void setupListeners() {
    // Listen for shared space update/create events
    connector.listen("shared_space", (event) {
      // Make sure the conversation is valid and exists on the client
      final conversationAdr = LPHAddress.from(event.data["space"]["conv"]);
      if (conversationAdr.isError()) {
        return;
      }
      final conversation = ConversationController.conversations[conversationAdr];
      if (conversation == null) {
        return;
      }

      // Parse the space and make sure it's valid
      final sharedSpace = SharedSpace.fromJson(event.data["space"], conversation.key);
      if (sharedSpace.id != sharedSpace.container.roomId) {
        sendLog("WARNING: invalid space id received in conversation with server ${conversation.id.server}");
        return;
      }

      // Add it to the controller or update it
      SharedSpaceController.addSharedSpace(conversationAdr, sharedSpace);
    });

    // Listen for shared space deletion events
    connector.listen("shared_space_delete", (event) {
      // Make sure the conversation is valid
      final conversationAdr = LPHAddress.from(event.data["space"]["conv"]);
      if (conversationAdr.isError()) {
        return;
      }

      // Delete the thing from the controller
      SharedSpaceController.deleteSharedSpace(conversationAdr, event.data["id"], event.data["underlying"]);
    });
  }
}
