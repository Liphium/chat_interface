import 'dart:convert';

import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/status/error/server_offline_page.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountSetup extends Setup {
  AccountSetup() : super('loading.account', false);
  
  @override
  Future<Widget?> load() async {

    // Get account from database
    var res = await postRqAuthorized("/account/me", <String, dynamic>{});

    if(res.statusCode != 200) {
      return const LoginPage();
    }

    var body = jsonDecode(res.body);
    var account = body["account"];

    if(!body["success"]) {
      return const ServerOfflinePage();
    }

    // Set account
    StatusController controller = Get.find();

    controller.name.value = account["username"];
    controller.tag.value = account["tag"];
    return null;
  }
}