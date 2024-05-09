import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/standards/unicode_string.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountSetup extends Setup {
  AccountSetup() : super('loading.account', false);

  @override
  Future<Widget?> load() async {
    // Get account from database
    final body = await postAuthorizedJSON("/account/me", <String, dynamic>{});
    final account = body["account"];

    if (!body["success"]) {
      return ErrorPage(title: "server.error".tr);
    }

    // Set all account data
    StatusController controller = Get.find();
    controller.name.value = account["username"];
    if (account["display_name"] != "") {
      sendLog("HELLO DISPLAY NAME FROM SERVER ${account["display_name"]}");
      controller.displayName.value = UTFString.untransform(account["display_name"]);
    } else {
      controller.displayName.value = UTFString(account["username"]);
      sendLog("SETTING DISPLAY NAME ${controller.displayName.value.text}");
    }
    StatusController.ownAccountId = account["id"];

    // Init file paths with account id
    AttachmentController.initFilePath(account["id"]);

    // Set all permissions
    StatusController.permissions = List<String>.from(body["permissions"]);

    return null;
  }
}
