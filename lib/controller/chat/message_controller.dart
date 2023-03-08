import 'package:get/get.dart';

import '../../database/database.dart';

class MessageController extends GetxController {

  final loaded = false.obs;
  final selectedConversation = 0.obs;
  final messages = <MessageData>[].obs;

  void selectConversation(int value) async {
    selectedConversation.value = value;

    // Load messages
    messages.value = await (db.select(db.message)..where((tbl) => tbl.conversationId.equals(value))).get();
  }

  void newMessages() async {
    
    
  }

}