import 'package:get/get.dart';

class WritingController extends GetxController {

  // Conversation: [Users]
  final writing = <String, List<String>>{}.obs;

  // User: Conversation
  final writingUser = <String, String>{};

  void init(String id) {
    if(writing[id] != null) return;
    writing[id] = <String>[];
  }

  void add(String id, String userId) {
    if(writingUser[userId] != null) {
      remove(writingUser[userId]!, userId);
    }

    if (writing[id] == null) {
      writing[id] = <String>[userId];
    } else {
      writing[id] = <String>[...writing[id]!, userId];
    }

    writingUser[userId] = id;
  }

  void remove(String id, String userId) {
    if (writing[id] == null) {
      writing[id] = <String>[];
    } else {
      writing[id]!.remove(userId);
      writing[id] = <String>[...writing[id]!];
    }

    writingUser.remove(userId);
  }
}