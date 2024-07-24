part of 'message_feed.dart';

class MessageSendHelper {
  static final currentDraft = Rx<MessageDraft?>(null);
  static final drafts = <String, MessageDraft>{}; // ConversationId, Message draft

  /// Add a reply to the current message draft
  static void addReplyToCurrentDraft(Message message) {
    currentDraft.value?.answer.value = AnswerData(message.id, message.senderAccount, message.content, message.attachments);
  }

  /// Add a file to the current message draft
  static Future<bool> addFile(File file) async {
    if (currentDraft.value == null) {
      return false;
    }

    // Check if there are already too many attachments
    if (MessageSendHelper.currentDraft.value!.files.length >= 5) {
      showErrorPopup("error".tr, "file.too_many".tr);
      return false;
    }

    // Check if the file size is valid
    final size = await file.length();
    if (size > specialConstants[Constants.specialConstantMaxFileSize]! * 1000 * 1000) {
      showErrorPopup(
        "error",
        "file.too_large".trParams({
          "1": specialConstants[Constants.specialConstantMaxFileSize].toString(),
        }),
      );
      return false;
    }

    // Attach the file
    MessageSendHelper.currentDraft.value?.files.add(UploadData(file));

    return true;
  }
}

class AnswerData {
  final String id;
  final String senderAccount;
  final String content;
  final List<String> attachments;

  AnswerData(this.id, this.senderAccount, this.content, this.attachments);

  static String answerContent(MessageType type, String content, List<String> attachments, {FriendController? controller}) {
    switch (type) {
      case MessageType.text:
        if (content == "" && attachments.isEmpty) {
          content = "message.empty".tr;
        } else if (content == "" && attachments.isNotEmpty) {
          if (attachments.first.isURL) {
            content = attachments.first;
          } else {
            content = AttachmentContainer.fromJson(StorageType.cache, jsonDecode(attachments.first)).name;
          }
        }
        return content;
      case MessageType.call:
        return "chat.space_invite".tr;
      case MessageType.liveshare:
        return "chat.liveshare_request".tr;
      case MessageType.system:
        return "under.dev".tr;
    }
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
  final File file;
  final progress = 0.0.obs;

  UploadData(this.file);
}

/// Send a text message with files attached (files will be uploaded)
void sendTextMessageWithFiles(RxBool loading, String conversationId, String message, List<UploadData> files, String answer, Function() callback) async {
  if (loading.value) {
    return;
  }
  loading.value = true;

  // Upload files
  final attachments = <String>[];
  for (var file in files) {
    final res = await Get.find<AttachmentController>().uploadFile(file, StorageType.temporary, Constants.fileAttachmentTag);
    if (res.container == null) {
      showErrorPopup("error", res.message);
      callback.call();
      return;
    }
    await res.container!.precalculateWidthAndHeight();
    attachments.add(res.data);
  }

  loading.value = false;
  sendActualMessage(loading, conversationId, MessageType.text, attachments, base64Encode(utf8.encode(message)), answer, callback);
}

/// Send a text message with attachments
void sendTextMessage(RxBool loading, String conversationId, String message, List<String> attachments, String answer, Function() callback) async {
  if (loading.value) {
    return;
  }

  // Scan for links with remote images (and add them as attachments)
  if (attachments.isEmpty) {
    for (var line in message.split("\n")) {
      bool found = false;
      for (var word in line.split(" ")) {
        if (word.isURL) {
          for (var fileType in FileSettings.imageTypes) {
            if (word.endsWith(".$fileType")) {
              attachments.add(word);
              if (message.trim() == word) {
                message = "";
              }
              found = attachments.length > 3;
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
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final content = jsonEncode(<String, dynamic>{
    "c": message,
    "t": type.index,
    "a": attachments,
    "r": answer,
  });
  final info = SymmetricSequencedInfo.builder(content, stamp).finish(conversation.key);

  // Send message
  final json = await postNodeJSON("/conversations/message/send", <String, dynamic>{
    "conversation": conversation.id,
    "token_id": conversation.token.id,
    "token": conversation.token.token,
    "timestamp": stamp,
    "data": info,
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
  final msg = await Message.unpackInIsolate(conversation, json["message"]);
  Get.find<MessageController>().storeMessage(msg);
}
