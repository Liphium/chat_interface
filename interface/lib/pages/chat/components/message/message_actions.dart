part of 'message_feed.dart';

class UploadData {
  final XFile file;
  final progress = 0.0.obs;

  UploadData(this.file);
}

void sendTextMessageWithFiles(RxBool loading, String conversationId, String message, List<UploadData> files, Function() callback) async {
  if(loading.value) {
    return;
  }
  loading.value = true;

  // Upload files
  final attachments = <String>[];
  for(var file in files) {
    final res = await Get.find<AttachmentController>().uploadFile(file);
    sendLog("attached");
    if(!res.success) {
      showErrorPopup("error", res.message);
      callback.call();
      return;
    }
    attachments.add(res.data);
  }

  sendLog("sending...");

  loading.value = false;
  sendActualMessage(loading, conversationId, MessageType.text, attachments, base64Encode(utf8.encode(message)), callback);
}

void sendTextMessage(RxBool loading, String conversationId, String message, List<String> attachments, Function() callback) async {
  if(loading.value) {
    return;
  }
  loading.value = true;
  sendActualMessage(loading, conversationId, MessageType.text, attachments, base64Encode(utf8.encode(message)), callback);
}

void sendActualMessage(RxBool loading, String conversationId, MessageType type, List<String> attachments, String message, Function() callback) async {
  
  if(message.isEmpty && attachments.isEmpty) {
    callback.call();
    return;
  }
  loading.value = true;

  // Encrypt message with signature
  ConversationController controller = Get.find();
  final conversation = controller.conversations[conversationId]!;
  var key = conversation.key;
  var hash = hashSha(message + conversationId);
  sendLog("MESSAGE HASH SENT: $hash ${message + conversationId}");

  var encrypted = encryptSymmetric(jsonEncode(<String, dynamic>{
    "c": message,
    "t": type.index,
    "a": attachments,
    "s": signMessage(signatureKeyPair.secretKey, hash)
  }), key);

  // Send message
  final json = await postNodeJSON("/conversations/message/send", <String, dynamic>{
    "conversation": conversation.id,
    "token_id": conversation.token.id,
    "token": conversation.token.token,
    "data": encrypted
  });

  callback.call();
  if(!json["success"]) {
    loading.value = false;
    String message = "conv_msg_create.${json["error"]}";
    if(json["message"] == "server.error") {
      message = "server.error";
    }

    showMessage(SnackbarType.error, message.tr);
    return;
  }

  // Store message
  Get.find<MessageController>().storeMessage(Message.fromJson(json["message"]));
}