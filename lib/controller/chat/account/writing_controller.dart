import 'package:get/get.dart';

class WritingController extends GetxController {

  final writing = <int, List<int>>{}.obs;
  final writingUser = <int, int>{};

  void init(int id) {
    if(writing[id] != null) return;
    writing[id] = <int>[];
  }

  void add(int id, int userId) {
    if(writingUser[userId] != null) {
      remove(writingUser[userId]!, userId);
    }

    if (writing[id] == null) {
      writing[id] = <int>[userId];
    } else {
      writing[id] = <int>[...writing[id]!, userId];
    }

    writingUser[userId] = id;
  }

  void remove(int id, int userId) {
    if (writing[id] == null) {
      writing[id] = <int>[];
    } else {
      writing[id]!.remove(userId);
      writing[id] = <int>[...writing[id]!];
    }

    writingUser.remove(userId);
  }
}