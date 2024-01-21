import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
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
    final json = await postAuthorizedJSON("/account/friends/list", <String, dynamic>{
      "after": 0,
    });
    if (!json["success"]) {
      return const ErrorPage(title: "friends.error");
    }

    sendLog(json);

    final requestsDone = <String>[], friendsDone = <String>[];
    for (var friend in json["friends"]) {
      final decrypted = decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, friend["friend"]);
      final data = jsonDecode(decrypted);

      // Check if request or friend
      if (data["rq"]) {
        requestsDone.add(data["id"]);

        // Check if request is already in the database
        final sentRequest = Get.find<RequestController>().requestsSent.firstWhere((element) => element.id == data["id"], orElse: () => Request.mock("hi"));
        final request = Get.find<RequestController>().requests.firstWhere((element) => element.id == data["id"], orElse: () => Request.mock("hi"));
        if (request.id != "hi" || sentRequest.id != "hi") {
          if (request.vaultId == "") {
            request.vaultId = friend["id"];
            request.save(data["self"]);
          }

          continue;
        }

        if (data["self"]) {
          final rq = Request.fromStoredPayload(data, friend["updated_at"]);
          rq.vaultId = friend["id"];
          Get.find<RequestController>().addSentRequest(rq);
        } else {
          final rq = Request.fromStoredPayload(data, friend["updated_at"]);
          rq.vaultId = friend["id"];
          Get.find<RequestController>().addRequest(rq);
        }
      } else {
        friendsDone.add(data["id"]);

        final fr = Friend.fromStoredPayload(data, friend["updated_at"]);
        fr.vaultId = friend["id"];
        Get.find<FriendController>().add(fr);
      }
    }

    // Delete requests and friends that are not in the vault
    Get.find<RequestController>().requests.removeWhere((rq) {
      if (!requestsDone.contains(rq.id)) {
        Get.find<RequestController>().deleteSentRequest(rq, removal: false);
        return true;
      }
      return false;
    });

    Get.find<RequestController>().requestsSent.removeWhere((rq) {
      if (!requestsDone.contains(rq.id)) {
        Get.find<RequestController>().deleteSentRequest(rq, removal: false);
        return true;
      }
      return false;
    });

    Get.find<FriendController>().friends.removeWhere((key, value) {
      if (!friendsDone.contains(key)) {
        Get.find<FriendController>().remove(value, removal: false);
        return true;
      }
      return false;
    });

    // Add own account so status and stuff can be tracked there
    Get.find<FriendController>().addSelf();

    return null;
  }
}
