import 'dart:convert';

import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/pages/status/error/server_offline_page.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';

late final String storedActionKey;

class StoredActionsSetup extends Setup {
  StoredActionsSetup() : super('loading.stored_actions', false);
  
  @override
  Future<Widget?> load() async {

    // Get account from database
    final res = await postRqAuthorized("/stored_actions/list", <String, dynamic>{});
    if(res.statusCode != 200) {
      return const LoginPage();
    }

    final body = jsonDecode(res.body);
    if(!body["success"]) {
      return const ServerOfflinePage();
    }

    storedActionKey = body["key"];
    final actions = body["actions"] as List<dynamic>;
    if(actions.isEmpty) {
      return null;
    }

    for (var element in actions) {
      await processStoredAction(element["id"], element["payload"]);
    }

    return null;
  }
}