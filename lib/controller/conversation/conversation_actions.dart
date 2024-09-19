part of 'conversation_controller.dart';

class MemberContainer {
  late final LPHAddress id;

  MemberContainer(this.id);
  MemberContainer.fromJson(Map<String, dynamic> json) : id = LPHAddress.from(json["id"]);

  MemberContainer.decrypt(String cipherText, SecureKey key) {
    final json = jsonDecode(decryptSymmetric(cipherText, key));
    id = LPHAddress.from(json["id"]);
  }
  String encrypted(SecureKey key) => encryptSymmetric(jsonEncode(<String, dynamic>{"id": id.encode()}), key);
}

class ConversationToken {
  final LPHAddress id;
  final String token;

  ConversationToken(this.id, this.token);
  ConversationToken.fromJson(Map<String, dynamic> json)
      : id = LPHAddress.from(json["id"]),
        token = json["token"];

  String toJson() => jsonEncode(toMap());
  Map<String, dynamic> toMap() => <String, dynamic>{"id": id.encode(), "token": token};
}

class ConversationContainer {
  late final String name;

  ConversationContainer(this.name);
  ConversationContainer.fromJson(Map<String, dynamic> json) : name = json["name"];

  ConversationContainer.decrypt(String cipherText, SecureKey key) {
    final json = jsonDecode(decryptSymmetric(cipherText, key));
    name = json["name"];
  }
  String encrypted(SecureKey key) => encryptSymmetric(jsonEncode(<String, dynamic>{"name": name}), key);

  Map<String, dynamic> toJson() => <String, dynamic>{"name": name};
}

const directMessagePrefix = "DM_";

// Wrapper for consistent DM and Group conversation handling
Future<bool> openDirectMessage(Friend friend) async {
  final conversation = Get.find<ConversationController>().conversations.values.firstWhere(
        (element) => element.members.length == 2 && element.members.values.any((element) => element.address == friend.id),
        orElse: () => Conversation(LPHAddress.error(), "", model.ConversationType.directMessage, ConversationToken(LPHAddress.error(), ""),
            ConversationContainer(""), "", 0, 0),
      );
  if (!conversation.id.isError()) {
    Get.find<MessageController>().selectConversation(conversation);
    return true;
  }

  return _openConversation([friend], directMessagePrefix + friend.id.id);
}

Future<bool> openGroupConversation(List<Friend> friends, String name) {
  return _openConversation(friends, name);
}

// Open conversation with a group of friends
Future<bool> _openConversation(List<Friend> friends, String name) async {
  if (Get.find<ConversationController>().conversations.length >= specialConstants["max_conversation_amount"]!) {
    showErrorPopup("conversations.error".tr, "conversations.amount".trParams({"amount": specialConstants["max_conversation_amount"].toString()}));
    return false;
  }

  // Prepare the conversation
  final conversationKey = randomSymmetricKey();
  final ownMemberContainer = MemberContainer(StatusController.ownAddress).encrypted(conversationKey);
  final memberContainers = <LPHAddress, String>{};
  for (final friend in friends) {
    final container = MemberContainer(friend.id);
    memberContainers[friend.id] = container.encrypted(conversationKey);
  }
  final conversationContainer = ConversationContainer(name);
  final encryptedData = conversationContainer.encrypted(conversationKey);

  if (name.length > specialConstants[Constants.specialConstantMaxConversationNameLength]!) {
    showErrorPopup("conversations.error".tr,
        "conversations.name.length".trParams({"length": specialConstants[Constants.specialConstantMaxConversationNameLength].toString()}));
    return false;
  }

  if (friends.length > specialConstants[Constants.specialConstantMaxConversationMembers]!) {
    showErrorPopup("conversations.error".tr,
        "conversations.members.size".trParams({"size": specialConstants[Constants.specialConstantMaxConversationMembers].toString()}));
    return false;
  }

  // Create the conversation
  final body = await postNodeJSON("/conversations/open", <String, dynamic>{
    "accountData": ownMemberContainer,
    "members": memberContainers.values.toList(),
    "data": encryptedData,
  });
  if (!body["success"]) {
    showErrorPopup("error".tr, "error.unknown".tr);
    return false;
  }

  //* Send the stuff to all other members
  final conversationController = Get.find<ConversationController>();

  final packagedKey = packageSymmetricKey(conversationKey);
  final convId = LPHAddress.from(body["conversation"]);
  final conversation = Conversation(convId, "", model.ConversationType.values[body["type"]], ConversationToken.fromJson(body["admin_token"]),
      conversationContainer, packagedKey, 0, DateTime.now().millisecondsSinceEpoch);
  final members = <Member>[];
  for (var friend in friends) {
    final token = ConversationToken.fromJson(body["tokens"][hashSha(memberContainers[friend.id]!)]);
    await sendAuthenticatedStoredAction(friend, _conversationPayload(convId, token, packagedKey, friend));
    members.add(Member(token.id, friend.id, MemberRole.user));
  }

  // Add the new conversation and subscribe
  await conversationController.addCreated(conversation, members, admin: Member(conversation.token.id, StatusController.ownAddress, MemberRole.admin));
  subscribeToConversation(conversation.token, deletions: false);

  return true;
}

/// Add a friend to a conversation by generating a new token for them and then
/// sending it to them by using a authenticated stored action.
Future<bool> addToConversation(Conversation conv, Friend friend) async {
  // Generate a new conversation token for the friend
  final json = await postNodeJSON("/conversations/generate_token", {
    "token": conv.token.toMap(),
    "data": MemberContainer(friend.id).encrypted(conv.key),
  });

  if (!json["success"]) {
    return false;
  }

  final result = await sendAuthenticatedStoredAction(
      friend, _conversationPayload(conv.id, ConversationToken.fromJson(json), packageSymmetricKey(conv.key), friend));
  return result;
}

Map<String, dynamic> _conversationPayload(LPHAddress id, ConversationToken token, String packagedKey, Friend friend) {
  final signature = signMessage(signatureKeyPair.secretKey, "$id${friend.id}");
  return authenticatedStoredAction("conv", {
    "id": id.encode(),
    "sg": signature,
    "token": token.toJson(),
    "key": packagedKey,
  });
}
