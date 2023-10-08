part of 'message_feed.dart';

void sendTextMessage(RxBool loading, String conversationId, String message, String attachments, Function() callback) async {
  sendActualMessage(loading, conversationId, MessageType.text, attachments, message, callback);
}

void sendActualMessage(RxBool loading, String conversationId, MessageType type, String attachments, String message, Function() callback) async {
  loading.value = true;

  // Encrypt message with signature
  ConversationController controller = Get.find();
  final conversation = controller.conversations[conversationId]!;
  var key = conversation.key;
  var hash = hashSha(message); // TODO: Signatures

  var encrypted = encryptSymmetric(jsonEncode(<String, dynamic>{
    "c": message,
    "t": type.name,
    "a": attachments
  }), key);

  // Send message
  print(conversation.id + " | " + conversation.token.id + " | " + conversation.token.token + " | " + encrypted);
  final json = await postNodeJSON("/conversations/message/send", <String, dynamic>{
    "conversation": conversation.id,
    "token_id": conversation.token.id,
    "token": conversation.token.token,
    "data": encrypted
  });

  callback.call();
  if(!json["success"]) {
    loading.value = false;
    String message = "conv_msg_create.${json["status"]}";
    if(json["message"] == "server.error") {
      message = "server.error";
    }

    showMessage(SnackbarType.error, message.tr);
    return;
  }

  // Store message
  Get.find<MessageController>().storeMessage(Message.fromJson(json["message"]));

  /* OLD CODE FOR REFERENCE
  connector.sendAction(messaging.Message("conv_msg_create", <String, dynamic>{
    "conversation": conversation.id,
    "token_id": conversation.token.id,
    "token": conversation.token.token,
    "data": encrypted
  }), handler: (event) {
    callback.call();
    if(event.data["success"]) return;

    String message = "conv_msg_create.${event.data["status"]}";
    if(event.data["message"] == "server.error") {
      message = "server.error";
    }

    showMessage(SnackbarType.error, message.tr);
  });
  */
}