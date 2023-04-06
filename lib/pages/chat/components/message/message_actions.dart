part of 'message_feed.dart';

void sendTextMessage(RxBool loading, int conversation, String message, String attachments, Function() callback) async {
  sendActualMessage(loading, conversation, "text", attachments, message, callback);
}

void sendActualMessage(RxBool loading, int conversation, String type, String attachments, String message, Function() callback) async {
  loading.value = true;

  // Encrypt message with signature
  ConversationController controller = Get.find();
  var key = controller.conversations[conversation]!.key;
  var hash = hashSha(message);

  var encrypted = encryptAES(jsonEncode(<String, dynamic>{
    "c": message,
    "s": sign(asymmetricKeyPair.privateKey, hash),
    "t": type,
    "a": attachments
  }), key).base64;

  connector.sendAction(messaging.Message("conv_msg_create", <String, dynamic>{
    "conversation": conversation,
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
}