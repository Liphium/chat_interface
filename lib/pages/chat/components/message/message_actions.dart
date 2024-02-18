part of 'message_feed.dart';

class MessageSendHelper {
  static final currentDraft = Rx<MessageDraft?>(null);
  static final drafts = <String, MessageDraft>{}; // ConversationId, Message draft

  static void addReplyToCurrentDraft(Message message) {
    currentDraft.value?.answer.value = AnswerData(message.id, message.senderAccount, message.content, message.attachments);
  }
}

class AnswerData {
  final String id;
  final String senderAccount;
  final String content;
  final List<String> attachments;

  AnswerData(this.id, this.senderAccount, this.content, this.attachments);

  static String answerContent(String content, List<String> attachments, {FriendController? controller}) {
    if (content == "" && attachments.isEmpty) {
      content = "message.empty".tr;
    } else if (content == "" && attachments.isNotEmpty) {
      content = AttachmentContainer.fromJson(StorageType.cache, jsonDecode(attachments.first)).name;
    }
    return content;
  }
}

class MessageDraft {
  final String conversationId;
  final answer = Rx<AnswerData?>(null);
  String message;
  final files = <UploadData>[].obs;
  final attachments = <String>[];

  MessageDraft(this.conversationId, this.message);
}

class UploadData {
  final XFile file;
  final progress = 0.0.obs;

  UploadData(this.file);
}

void sendTextMessageWithFiles(RxBool loading, String conversationId, String message, List<UploadData> files, String answer, Function() callback) async {
  if (loading.value) {
    return;
  }
  loading.value = true;

  // Upload files
  final attachments = <String>[];
  for (var file in files) {
    final res = await Get.find<AttachmentController>().uploadFile(file, StorageType.temporary);
    if (res.container == null) {
      showErrorPopup("error", res.message);
      callback.call();
      return;
    }
    attachments.add(res.data);
  }

  loading.value = false;
  sendActualMessage(loading, conversationId, MessageType.text, attachments, base64Encode(utf8.encode(message)), answer, callback);
}

void sendTextMessage(RxBool loading, String conversationId, String message, List<String> attachments, String answer, Function() callback) async {
  if (loading.value) {
    return;
  }

  // Scan for links with remote images
  if (attachments.isEmpty) {
    for (var line in message.split("\n")) {
      bool found = false;
      for (var word in line.split(" ")) {
        if (word.isURL) {
          for (var fileType in FileSettings.imageTypes) {
            if (word.endsWith(".$fileType")) {
              attachments.add(word);
              found = true;
              break;
            }
          }
          if (found) {
            break;
          }
        }
      }
      if (found) {
        break;
      }
    }
  }

  loading.value = true;
  sendActualMessage(loading, conversationId, MessageType.text, attachments, base64Encode(utf8.encode(message)), answer, callback);
}

void sendActualMessage(RxBool loading, String conversationId, MessageType type, List<String> attachments, String message, String answer, Function() callback) async {
  if (message.isEmpty && attachments.isEmpty) {
    callback.call();
    return;
  }
  loading.value = true;

  // Encrypt message with signature
  ConversationController controller = Get.find();
  final conversation = controller.conversations[conversationId]!;
  var key = conversation.key;
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final contentJson = <String, dynamic>{
    "c": message,
    "t": type.index,
    "a": attachments,
    "r": answer,
  };
  var hash = hashSha(jsonEncode(contentJson) + stamp.toStringAsFixed(0) + conversationId); // Adding a time stamp to the message to prevent replay attacks
  sendLog("MESSAGE HASH SENT: $hash ${message + conversationId}");

  var encrypted = encryptSymmetric(
      jsonEncode(<String, dynamic>{
        "c": message,
        "t": type.index,
        "a": attachments,
        "r": answer,
        "s": signMessage(signatureKeyPair.secretKey, hash),
      }),
      key);

  // Send message
  final json = await postNodeJSON("/conversations/message/send", <String, dynamic>{
    "conversation": conversation.id,
    "token_id": conversation.token.id,
    "token": conversation.token.token,
    "timestamp": stamp,
    "data": encrypted,
  });

  callback.call();
  if (!json["success"]) {
    loading.value = false;
    String message = "conv_msg_create.${json["error"]}";
    if (json["message"] == "server.error") {
      message = "server.error";
    }

    showMessage(SnackbarType.error, message.tr);
    return;
  }

  // Store message
  Get.find<MessageController>().storeMessage(Message.fromJson(json["message"]));
}
