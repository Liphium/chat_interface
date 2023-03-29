part of 'message_feed.dart';

void sendMessage(RxBool loading, int conversation, String message, Function() callback) {
  loading.value = true;

  // Encrypt message with signature
  ConversationController controller = Get.find();
  var key = controller.conversations[conversation]!.key;
  var hash = hashSha(message);

  var encrypted = encryptAES(jsonEncode(<String, dynamic>{
    "c": message,
    "s": sign(asymmetricKeyPair.privateKey, hash)
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