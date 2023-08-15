
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

    print(json);

    final requestsDone = <String>[], friendsDone = <String>[];
    for(var friend in json["friends"]) {
      final decrypted = decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, friend["friend"]);
      final data = jsonDecode(decrypted);

      // Check if request or friend
      if(data["rq"]) {
        requestsDone.add(data["id"]);

        // Check if request is already in the database
        final request = Get.find<RequestController>().requests.firstWhere((element) => element.id == data["id"], orElse: () => Request.mock("hi"));
        if(request.id != "hi") {

          if(request.vaultId == "") {
            request.vaultId = friend["id"];
            request.save(data["self"]);
          }

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
        friendsDone.add(data["id"]);
        
        final fr = Friend.fromStoredPayload(data);
        fr.vaultId = friend["id"];
        Get.find<FriendController>().add(fr);
      }

    }
    
    // Delete requests and friends that are not in the vault
    for(var request in Get.find<RequestController>().requests) {
      if(!requestsDone.contains(request.id)) {
        Get.find<RequestController>().deleteRequest(request);
      }
    }

    for(var friend in Get.find<FriendController>().friends.values) {
      if(!friendsDone.contains(friend.id)) {
        Get.find<FriendController>().remove(friend);
      }
    }
    
    return null;
  }

}