import 'dart:convert';

import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../error/server_offline_page.dart';

class FriendsSetup extends Setup {
  FriendsSetup() : super('loading.friends');

  @override
  Future<Widget?> load() async {

    // Setup last fetch time
    var lastFetch = await (db.select(db.setting)..where((tbl) => tbl.key.equals("lastFetch"))).getSingleOrNull();
    if(lastFetch == null) {
      var first = DateTime.fromMillisecondsSinceEpoch(0);
      await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "lastFetch", value: first.millisecondsSinceEpoch.toString()));
      lastFetch = SettingData(key: "lastFetch", value: first.millisecondsSinceEpoch.toString());
    }

    var lastFetchTime = DateTime.fromMillisecondsSinceEpoch(int.parse(lastFetch.value));

    // Get new friends from server
    var res = await postRqAuthorized("/account/friends/list", <String, dynamic>{
      "request": false,
      "since": lastFetchTime.millisecondsSinceEpoch,
    });

    if(res.statusCode == 404) return const ServerOfflinePage();
    if(res.statusCode != 200) return const ErrorPage(title: "server.error");

    var body = jsonDecode(res.body);

    if(body["success"]) {
      var friends = body["friends"] as List<dynamic>;
      print("Friends: ${friends.length}");
      FriendController controller = Get.find();

      // Add new friends
      for(var friend in friends) {
        var friendData = Friend.fromJson(friend as Map<String, dynamic>);
        controller.friends.add(friendData);
      }

      // Update last fetch time
      await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "lastFetch", value: DateTime.now().millisecondsSinceEpoch.toString()));

    } else {
      return const ErrorPage(title: "server.error");
    }

    return null;
  }
}