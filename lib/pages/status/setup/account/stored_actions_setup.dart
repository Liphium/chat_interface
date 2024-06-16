import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

late String storedActionKey;

class StoredActionsSetup extends Setup {
  StoredActionsSetup() : super('loading.stored_actions', false);

  @override
  Future<Widget?> load() async {
    // Get account from database
    final body = await postAuthorizedJSON("/account/stored_actions/list", <String, dynamic>{});
    if (!body["success"]) {
      return ErrorPage(
        title: "server.error".tr,
      );
    }

    sendLog("LOADING");

    storedActionKey = body["key"];
    final actions = body["actions"] as List<dynamic>;
    if (actions.isEmpty) {
      return null;
    }

    for (var element in actions) {
      sendLog("hello wrold");
      sendLog(element);
      await processStoredAction(element);
    }

    return null;
  }
}
