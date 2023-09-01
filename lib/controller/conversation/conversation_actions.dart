part of 'conversation_controller.dart';

class MemberContainer {

  late final String id;

  MemberContainer(this.id);
  MemberContainer.fromJson(Map<String, dynamic> json) : id = json["id"];

  MemberContainer.decrypt(String cipherText, SecureKey key) {
    final json = jsonDecode(decryptSymmetric(cipherText, key));
    id = json["id"];
  }
  String encrypted(SecureKey key) => encryptSymmetric(id, key);

}

class ConversationContainer {

  late final String name;

  ConversationContainer(this.name);
  ConversationContainer.fromJson(Map<String, dynamic> json) : name = json["name"];

  ConversationContainer.decrypt(String cipherText, SecureKey key) {
    final json = jsonDecode(decryptSymmetric(cipherText, key));
    name = json["name"];
  }
  String encrypted(SecureKey key) => encryptSymmetric(jsonEncode(<String, dynamic>{
    "name": name
  }), key);

  String toJson() => jsonEncode(<String, dynamic>{
    "name": name
  });

}

const directMessagePrefix = "DM_";

// Wrapper for consistent DM and Group conversation handling
Future<bool> openDirectMessage(Friend friend) async {

  if(Get.find<ConversationController>().conversations.values.any((element) => element.members.length == 1 && element.members.first.account == friend.name)) {
    // TODO: Open conversation (in UI)
    return false;
  }

  sendLog(directMessagePrefix + friend.id);
  return _openConversation([friend], directMessagePrefix + friend.id);
}

Future<bool> openGroupConversation(List<Friend> friends, String name) {

  // TODO: Check if it exists and open in UI

  return _openConversation(friends, name);
}

// Open conversation with a group of friends
Future<bool> _openConversation(List<Friend> friends, String name) async {

  // Prepare the conversation
  final conversationKey = randomSymmetricKey();
  final ownMemberContainer = MemberContainer(Get.find<StatusController>().id.value).encrypted(conversationKey);
  final memberContainers = <String>[];
  for(final friend in friends) {
    final container = MemberContainer(friend.id);
    memberContainers.add(container.encrypted(conversationKey));
  }
  final conversationContainer = ConversationContainer(name);
  final encryptedData = conversationContainer.encrypted(conversationKey);

  sendLog(name.length.toString() + " | " + name + " | " + specialConstants["max_conversation_name_length"].toString());

  if(name.length > specialConstants["max_conversation_name_length"]) {
    showErrorPopup("conversations.error".tr, "conversations.name.length".trParams({
      "length": specialConstants["max_conversation_name_length"].toString()
    }));
    return false;
  }

  if(friends.length > specialConstants["max_conversation_members"]) {
    showErrorPopup("conversations.error".tr, "conversations.members.size".trParams({
      "size": specialConstants["max_conversation_members"].toString()
    }));
    return false;
  }

  // Create the conversation
  final body = await postNodeJSON("/conversations/open", <String, dynamic>{
    "accountData": ownMemberContainer,
    "members": memberContainers,
    "data": encryptedData
  });
  if(!body["success"]) {
    showErrorPopup("error".tr, "error.unknown".tr);
    return false;
  }

  //* Send the stuff to all other members
  final conversationController = Get.find<ConversationController>();

  final conversation = Conversation(body["conversation"], conversationContainer, conversationKey);
  await conversationController.addCreated(conversation, friends, admin: Member(Get.find<StatusController>().id.value, MemberRole.admin));

  final packagedKey = packageSymmetricKey(conversationKey);
  for(var friend in friends) {
    await sendAuthenticatedStoredAction(friend, storedAction("conv", <String, dynamic>{
      "id": body["conversation"],
      "key": packagedKey,
    }));
  }

  return true;
} 