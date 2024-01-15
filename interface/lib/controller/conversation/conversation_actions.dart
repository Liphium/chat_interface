part of 'conversation_controller.dart';

class MemberContainer {
  late final String id;

  MemberContainer(this.id);
  MemberContainer.fromJson(Map<String, dynamic> json) : id = json["id"];

  MemberContainer.decrypt(String cipherText, SecureKey key) {
    final json = jsonDecode(decryptSymmetric(cipherText, key));
    id = json["id"];
  }
  String encrypted(SecureKey key) => encryptSymmetric(jsonEncode(<String, dynamic>{"id": id}), key);
}

class ConversationToken {
  final String id;
  final String token;

  ConversationToken(this.id, this.token);
  ConversationToken.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        token = json["token"];

  String toJson() => jsonEncode(toMap());
  Map<String, dynamic> toMap() => <String, dynamic>{"id": id, "token": token};
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

  String toJson() => jsonEncode(<String, dynamic>{"name": name});
}

const directMessagePrefix = "DM_";

// Wrapper for consistent DM and Group conversation handling
Future<bool> openDirectMessage(Friend friend) async {
  final conversation = Get.find<ConversationController>().conversations.values.firstWhere(
        (element) => element.members.length == 2 && element.members.values.any((element) => element.account == friend.id),
        orElse: () => Conversation("", "", model.ConversationType.directMessage, ConversationToken("", ""), ConversationContainer(""), randomSymmetricKey(), 0),
      );
  if (conversation.id != "") {
    Get.find<MessageController>().selectConversation(conversation);
    return true;
  }

  sendLog(directMessagePrefix + friend.id);
  return _openConversation([friend], directMessagePrefix + friend.id);
}

Future<bool> openGroupConversation(List<Friend> friends, String name) {
  return _openConversation(friends, name);
}

// Open conversation with a group of friends
Future<bool> _openConversation(List<Friend> friends, String name) async {
  if (Get.find<ConversationController>().conversations.length >= specialConstants["max_conversation_amount"]) {
    showErrorPopup("conversations.error".tr, "conversations.amount".trParams({"amount": specialConstants["max_conversation_amount"].toString()}));
    return false;
  }

  // Prepare the conversation
  final conversationKey = randomSymmetricKey();
  final ownMemberContainer = MemberContainer(Get.find<StatusController>().id.value).encrypted(conversationKey);
  final memberContainers = <String, String>{};
  for (final friend in friends) {
    final container = MemberContainer(friend.id);
    memberContainers[friend.id] = (container.encrypted(conversationKey));
  }
  final conversationContainer = ConversationContainer(name);
  final encryptedData = conversationContainer.encrypted(conversationKey);

  sendLog("${name.length} | $name | ${specialConstants["max_conversation_name_length"]}");

  if (name.length > specialConstants["max_conversation_name_length"]) {
    showErrorPopup("conversations.error".tr, "conversations.name.length".trParams({"length": specialConstants["max_conversation_name_length"].toString()}));
    return false;
  }

  if (friends.length > specialConstants["max_conversation_members"]) {
    showErrorPopup("conversations.error".tr, "conversations.members.size".trParams({"size": specialConstants["max_conversation_members"].toString()}));
    return false;
  }

  // Create the conversation
  final body = await postNodeJSON("/conversations/open", <String, dynamic>{"accountData": ownMemberContainer, "members": memberContainers.values.toList(), "data": encryptedData});
  if (!body["success"]) {
    showErrorPopup("error".tr, "error.unknown".tr);
    return false;
  }

  //* Send the stuff to all other members
  final conversationController = Get.find<ConversationController>();

  final conversation = Conversation(body["conversation"], "", model.ConversationType.values[body["type"]], ConversationToken.fromJson(body["admin_token"]), conversationContainer, conversationKey,
      DateTime.now().millisecondsSinceEpoch);
  final members = <Member>[];
  final packagedKey = packageSymmetricKey(conversationKey);
  for (var friend in friends) {
    final token = ConversationToken.fromJson(body["tokens"][hashSha(memberContainers[friend.id]!)]);
    final signature = signMessage(signatureKeyPair.secretKey, "${body["conversation"]}${friend.id}");
    await sendAuthenticatedStoredAction(
        friend,
        storedAction("conv", <String, dynamic>{
          "s": StatusController.ownAccountId,
          "id": body["conversation"],
          "sg": signature,
          "token": token.toJson(),
          "key": packagedKey,
        }));
    members.add(Member(token.id, friend.id, MemberRole.user));
  }

  final statusController = Get.find<StatusController>();
  await conversationController.addCreated(conversation, members, admin: Member(conversation.token.id, statusController.id.value, MemberRole.admin));
  subscribeToConversation(statusController.statusJson(), statusController.generateFriendId(), conversation.token);

  return true;
}
