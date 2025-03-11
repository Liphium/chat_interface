part of 'message_provider.dart';

class MessageSendHelper {
  static final currentDraft = Rx<MessageDraft?>(null);
  static final drafts = <String, MessageDraft>{}; // TargetID -> Message draft

  /// Add a reply to the current message draft
  static void addReplyToCurrentDraft(Message message) {
    currentDraft.value?.answer.value = AnswerData(message.id, message.senderAddress, message.content, message.attachments);
  }

  /// Add a file to the current message draft
  static Future<bool> addFile(XFile file) async {
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
  final LPHAddress senderAddress;
  final String content;
  final List<String> attachments;

  AnswerData(this.id, this.senderAddress, this.content, this.attachments);

  /// Convert a message to the answer content for the reply container
  static String answerContent(MessageType type, String content, List<String> attachments, {FriendController? controller}) {
    // Return different information based on every type
    switch (type) {
      case MessageType.text:
        // If there is no content, say that the message is empty
        if (content == "" && attachments.isEmpty) {
          content = "message.empty".tr;
        } else if (content == "" && attachments.isNotEmpty) {
          // If the message is empty and there are attachments, show the name of the first one
          if (attachments.first.isURL) {
            content = attachments.first;
          } else {
            content = AttachmentController.fromJson(StorageType.cache, jsonDecode(attachments.first)).name;
          }
        }
        return content;
      case MessageType.call:
        return "chat.space_invite".tr;
      case MessageType.liveshare:
        return "chat.zapshare_request".tr;
      case MessageType.system:
        return "under.dev".tr;
    }
  }
}

class MessageDraft {
  final String target;
  final answer = Rx<AnswerData?>(null);
  String message;
  final files = <UploadData>[].obs;
  final attachments = <String>[];

  MessageDraft(this.target, this.message);
}

class UploadData {
  final XFile file;
  final progress = 0.0.obs;

  UploadData(this.file);
}
