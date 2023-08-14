
import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendsSetup extends Setup {
  FriendsSetup() : super("loading.friends", false);

  @override
  Future<Widget?> load() async {
    
    // Load requests and friends from database
    await Get.find<RequestController>().loadRequests();
    await Get.find<FriendController>().loadFriends();

    // Load friends from vault
    final res = await postRqAuthorized("/account/friends/list", <String, dynamic>{});

    if(res.statusCode != 200) {
      return const ErrorPage(title: "friends.error");
    }

    final json = jsonDecode(res.body);
    if(!json["success"]) {
      return const ErrorPage(title: "friends.error");
    }

    for(var friend in json["friends"]) {
      final decrypted = decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, friend["friend"]);
      final data = jsonDecode(decrypted);

      // Check if request or friend
      if(data["rq"]) {
        
        // Check if request is already in the database
        final request = Get.find<RequestController>().requests.firstWhere((element) => element.id == data["id"], orElse: () => Request.mock("hi"));
        if(request.id == "hi") {
          continue;
        }

        if(data["self"]) {
          final rq = Request.fromStoredPayload(data);
          rq.vaultId = friend["id"];
          Get.find<RequestController>().addSentRequest(rq);
        } else {
          final rq = Request.fromStoredPayload(data);
          rq.vaultId = friend["id"];
          Get.find<RequestController>().addRequest(rq);
        }

      } else {
        
        final fr = Friend.fromStoredPayload(data);
        fr.vaultId = friend["id"];
        Get.find<FriendController>().add(fr);
      }

    }

    return null;
  }

}