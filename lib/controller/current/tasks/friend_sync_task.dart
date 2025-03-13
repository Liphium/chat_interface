import 'dart:async';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';

class FriendsSyncTask extends SynchronizationTask {
  FriendsSyncTask() : super("loading.friends", const Duration(seconds: 30));

  @override
  Future<String?> init() async {
    // Load requests and friends from database
    await RequestController.loadRequests();
    await FriendController.loadFriends();

    // Make sure to set the completer to null again
    AccountStep.keyCompleter = Completer();

    // Add self as friend (without keys)
    FriendController.addSelf();

    return null;
  }

  @override
  Future<String?> refresh() {
    return FriendsVault.refreshFriendsVault();
  }

  @override
  void onRestart() {}
}
