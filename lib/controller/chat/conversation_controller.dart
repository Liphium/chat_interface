import 'package:get/get.dart';

class ConversationController extends GetxController {

  final loaded = false.obs;
  final conversations = <Conversation>[].obs;

}

class Conversation {
  
  final int id;
  final String name;

  Conversation(this.id, this.name);
  Conversation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"];
}