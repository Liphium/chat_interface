part of 'message_feed.dart';

void testFileUpload(XFile file) {
  _attachFile(UploadData(file)).then((value) {
    sendLog("File upload: ${value.success} - ${value.message} - ${value.data}");
  });
}

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
    final res = await _attachFile(file);
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

Future<_FileUploadResponse> _attachFile(UploadData data) async {
  final bytes = await data.file.readAsBytes();
  final key = randomSymmetricKey();
  final encrypted = encryptSymmetricBytes(bytes, key);
  final name = encryptSymmetric(data.file.name, key);

  // Upload file
  //final request = http.MultipartRequest("POST", server("/account/files/upload"));
  final formData = dio_rs.FormData.fromMap({
    "file": dio_rs.MultipartFile.fromBytes(encrypted, filename: name),
    "name": name,
    "key": encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, packageSymmetricKey(key)),
    "extension": data.file.name.split(".").last
  });
  /*
  request.files.add(http.MultipartFile.fromBytes("file", encrypted, filename: name));
  request.fields.addAll(<String, String>{
    "name": name,
    "key": encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, packageSymmetricKey(key)),
    "extension": data.file.name.split(".").last
  });
  request.headers.addAll({
    "Content-Type": "multipart/form-data",
    "Authorization": "Bearer $sessionToken"
  });*/

  sendLog(server("/account/files/upload").toString());
  final res = await dio.post(
    server("/account/files/upload").toString(), 
    data: formData, 
    options: dio_rs.Options(headers: {
      "Content-Type": "multipart/form-data",
      "Authorization": "Bearer $sessionToken"
    }), 
    onSendProgress: (count, total) {
      data.progress.value = count / total;
      sendLog(data.progress.value);
    },
  );

  if(res.statusCode != 200) {
    return _FileUploadResponse(false, "server.error", "");
  }

  final json = res.data;
  if(!json["success"]) {
    return _FileUploadResponse(false, json["error"], "");
  }

  // Copy file to cloud_files directory
  final instanceFolder = path.join((await getApplicationSupportDirectory()).path, "cloud_files");
  final dir = Directory(instanceFolder);
  await dir.create();

  final file2 = File(path.join(dir.path, json["id"].toString()));
  await file2.writeAsBytes(bytes);
  db.cloudFile.insertOne(CloudFileCompanion.insert(id: json["id"], name: data.file.name, path: json["url"], key: packageSymmetricKey(key)));

  return _FileUploadResponse(true, "success", jsonEncode({
    "id": json["id"],
    "name": data.file.name,
    "key": packageSymmetricKey(key),
    "url": json["url"]
  }));
}