import 'package:get/get.dart';

class ConversationController extends GetxController {

  final loaded = false.obs;
  final conversations = <Conversation>[].obs;

  void newConversations(dynamic conversations) async {
    loaded.value = true;
    if(conversations == null) {
      return;
    }

    for (var conversation in conversations) {
      this.conversations.add(Conversation.fromJson(conversation));
    }
  }

}

class Conversation {
  
  final int id;
  final String data;

  Conversation(this.id, this.data);
  Conversation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        data = json["data"];
}