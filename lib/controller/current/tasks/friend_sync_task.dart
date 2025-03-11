import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:get/get.dart';

class FriendsSyncTask extends SynchronizationTask {
  FriendsSyncTask() : super("loading.friends", const Duration(seconds: 30));

  @override
  Future<String?> init() async {
    // Load requests and friends from database
    await Get.find<RequestController>().loadRequests();
    await Get.find<FriendController>().loadFriends();

    // Add self as friend (without keys)
    Get.find<FriendController>().addSelf();

    return null;
  }

  @override
  Future<String?> refresh() {
    return FriendsVault.refreshFriendsVault();
  }

  @override
  void onRestart() {}
}
