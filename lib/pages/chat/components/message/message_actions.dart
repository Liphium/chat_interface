part of 'message_feed.dart';

void sendTextMessage(RxBool loading, int conversation, String message, String attachments, Function() callback) async {

  // April fools
  var rng = Random();
  if(rng.nextBool() && rng.nextBool() && rng.nextBool()) {
    message = "👀";
    String url = "https://www.google.com/url?url=https://s.click.aliexpress.com/deep_link.htm%3Faff_short_key%3DUneMJZVf%26dl_target_url%3Dhttps%253A%252F%252Fde.aliexpress.com%252Fitem%252F1005004370490712.html%253F_randl_currency%253DEUR%2526_randl_shipto%253DDE%2526src%253Dgoogle&rct=j&q=&esrc=s&sa=U&ved=0ahUKEwiWyemc94H-AhWXQ_EDHQMCBGIQguUECMwK&usg=AOvVaw3t3oomkhOmGZAxN4PYTg9Q";

    await launchUrl(Uri.parse(url));
  }

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