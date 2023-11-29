part of 'message_feed.dart';

void sendTextMessageWithFiles(RxBool loading, String conversationId, String message, List<XFile> files, Function() callback) async {
  if(loading.value) {
    return;
  }
  loading.value = true;

  // Upload files
  final attachments = <String>[];
  for(var file in files) {
    final res = await _attachFile(file);
    if(!res.success) {
      showErrorPopup("error", res.message);
      callback.call();
      return;
    }
    attachments.add(res.data);
  }

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
  loading.value = true;

  // Encrypt message with signature
  ConversationController controller = Get.find();
  final conversation = controller.conversations[conversationId]!;
  var key = conversation.key;
  var hash = hashSha(message); // TODO: Signatures

  var encrypted = encryptSymmetric(jsonEncode(<String, dynamic>{
    "c": message,
    "t": type.index,
    "a": attachments
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

class _FileUploadResponse {
  final bool success;
  final String message;
  final String data;

  _FileUploadResponse(this.success, this.message, this.data);
}

Future<_FileUploadResponse> _attachFile(XFile file) async {
  final bytes = await file.readAsBytes();
  sendLog("Original size: ${bytes.length}");
  final key = randomSymmetricKey();
  final encrypted = encryptSymmetricBytes(bytes, key);
  sendLog("Encrypted size: ${encrypted.length}");
  final name = encryptSymmetric(file.name, key);

  // Upload file
  final request = http.MultipartRequest("POST", server("/account/files/upload"));
  request.files.add(http.MultipartFile.fromBytes("file", encrypted, filename: name));
  request.fields.addAll(<String, String>{
    "name": name,
    "key": encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, packageSymmetricKey(key)),
    "extension": file.name.split(".").last
  });
  request.headers.addAll({
    "Content-Type": "multipart/form-data",
    "Authorization": "Bearer $sessionToken"
  });

  final res = await request.send();
  if(res.statusCode != 200) {
    return _FileUploadResponse(false, "server.error", "");
  }

  final json = jsonDecode(await res.stream.bytesToString());
  if(!json["success"]) {
    return _FileUploadResponse(false, json["message"], "");
  }

  return _FileUploadResponse(true, "success", jsonEncode({
    "id": json["id"],
    "key": packageSymmetricKey(key),
    "url": json["url"]
  }));
}