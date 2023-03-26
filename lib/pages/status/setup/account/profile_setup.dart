import 'dart:convert';

import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/server_offline_page.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSetup extends Setup {
  ProfileSetup() : super('loading.profile', false);
  
  @override
  Future<Widget?> load() async {

    // Get profile from database
    var profiles = await (db.select(db.setting)..where((tbl) => tbl.key.equals("profile"))).get();
    if(profiles.isEmpty) return const LoginPage();

    // Load tokens from profile
    var profile = profiles.first;
    loadTokensFromPayload(jsonDecode(profile.value));

    print("session_tk: " + sessionToken);

    var session = getSessionFromJWT(sessionToken);

    // Refresh token
    var res = await postRqAuthorized("/auth/refresh", <String, dynamic>{
      "session": session,
      "token": refreshToken,
    });

    if(res.statusCode == 404) return const ServerOfflinePage();
    if(res.statusCode != 200) return const LoginPage();

    // Set new token (if refreshed)
    var body = jsonDecode(res.body);
    if(body["success"]) {
      loadTokensFromPayload(body);
      await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "profile", value: tokensToPayload()));
    } else {

      if(body["error"] == "session.duration") {
        return null;
      }

      Get.snackbar("loading.profile".tr, body["error"].tr);
      return const LoginPage();
    }

    return null;
  }
}