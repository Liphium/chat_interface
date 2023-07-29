
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendsSetup extends Setup {
  FriendsSetup() : super("loading.friends", false);

  @override
  Future<Widget?> load() async {
    
    // Load requests and friends from database
    await Get.find<RequestController>().loadRequests();
    await Get.find<FriendController>().loadFriends();

    // TODO: Load friend vault changes from server

    return null;
  }

}