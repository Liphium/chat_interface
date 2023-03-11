import 'dart:convert';

import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../error/server_offline_page.dart';
import '../fetch/fetch_setup.dart';

class FriendsSetup extends Setup {
  FriendsSetup() : super('loading.friends');

  @override
  Future<Widget?> load() async {

    // Get new friends from server
    var res = await postRqAuthorized("/account/friends/list", <String, dynamic>{
      "request": false,
      "since": lastFetchTime.millisecondsSinceEpoch,
    });

    if(res.statusCode == 404) return const ServerOfflinePage();
    if(res.statusCode != 200) return const ErrorPage(title: "server.error");

    var body = jsonDecode(res.body);

    FriendController controller = Get.find();
    if(body["success"]) {

      var friends = body["friends"];
      if (friends != null) {
        // Add new friends
        for(var friend in friends) {
          var friendData = Friend.fromJson(friend as Map<String, dynamic>);
          controller.insert(friendData);
        }
      }
    } else {
      return const ErrorPage(title: "server.error");
    }

    // Get friends from database
    var friends = await (db.select(db.friend)..orderBy([(tbl) => OrderingTerm(expression: tbl.id)])).get();
    controller.friends.addAll(friends.map((e) => Friend(e.id, e.name, e.tag)));

    return null;
  }
}