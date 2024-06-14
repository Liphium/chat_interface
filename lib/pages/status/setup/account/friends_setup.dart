import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/account/friends/requests_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/account/key_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

class FriendsSetup extends Setup {
  FriendsSetup() : super("loading.friends", false);

  @override
  Future<Widget?> load() async {
    // Load requests and friends from database
    await Get.find<RequestController>().loadRequests();
    await Get.find<FriendController>().loadFriends();

    // Refresh from server vault
    final error = await refreshFriendsVault();
    if (error != null) {
      return ErrorPage(title: error);
    }

    // Add own account so status and stuff can be tracked there
    Get.find<FriendController>().addSelf();

    return null;
  }
}

class _FriendsListResponse {
  final List<Request> requests;
  final List<Request> requestsSent;
  final List<Friend> friends;

  // Strings lists for later processing
  final List<String> friendIds = <String>[];
  final List<String> requestIds = <String>[];

  _FriendsListResponse(this.requests, this.requestsSent, this.friends) {
    for (var friend in friends) {
      friendIds.add(friend.id);
    }
    for (var request in requests) {
      requestIds.add(request.id);
    }
    for (var sentRequest in requestsSent) {
      requestIds.add(sentRequest.id);
    }
  }
}

/// Refresh all friends and load them from the vault (also removes what's not on the server)
Future<String?> refreshFriendsVault() async {
  // Load friends from vault
  final json = await postAuthorizedJSON("/account/friends/list", <String, dynamic>{
    "after": 0,
  });
  if (!json["success"]) {
    return "friends.error";
  }

  // Parse the JSON (in different isolate)
  final res = await sodiumLib.runIsolated(
    (sodium, keys, pairs) => _parseFriends(json, sodium, pairs[0]),
    keyPairs: [asymmetricKeyPair],
  );

  // Push requests
  final controller = Get.find<RequestController>();
  controller.requests.clear();
  for (var request in res.requests) {
    controller.addRequest(request);
  }
  controller.requestsSent.clear();
  for (var request in res.requestsSent) {
    controller.addSentRequest(request);
  }
  db.request.deleteWhere((t) => t.id.isIn(res.requestIds)); // Remove the other ones that aren't there

  // Push friends
  final friendController = Get.find<FriendController>();
  friendController.friends.clear();
  for (var friend in res.friends) {
    friendController.add(friend);
  }
  db.friend.deleteWhere((t) => t.id.isIn(res.friendIds)); // Remove the other ones that aren't there

  return null;
}

Future<_FriendsListResponse> _parseFriends(Map<String, dynamic> json, Sodium sodium, KeyPair pair) async {
  final friends = <Friend>[];
  final requests = <Request>[];
  final requestsSent = <Request>[];
  for (var friend in json["friends"]) {
    final decrypted = decryptAsymmetricAnonymous(pair.publicKey, pair.secretKey, friend["friend"], sodium);
    final data = jsonDecode(decrypted);

    // Check if request or friend
    if (data["rq"]) {
      if (data["self"]) {
        final rq = Request.fromStoredPayload(data, friend["updated_at"]);
        rq.vaultId = friend["id"];
        requestsSent.add(rq);
      } else {
        final rq = Request.fromStoredPayload(data, friend["updated_at"]);
        rq.vaultId = friend["id"];
        requests.add(rq);
      }
    } else {
      final fr = Friend.fromStoredPayload(data, friend["updated_at"]);
      fr.vaultId = friend["id"];
      friends.add(fr);
    }
  }

  return _FriendsListResponse(requests, requestsSent, friends);
}
