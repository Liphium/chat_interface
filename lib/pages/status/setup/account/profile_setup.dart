import 'dart:convert';

import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';

class ProfileSetup extends Setup {
  ProfileSetup() : super('loading.profile', false);

  @override
  Future<Widget?> load() async {
    // Get profile from database
    var profiles = await (db.select(db.setting)..where((tbl) => tbl.key.equals("profile"))).get();
    if (profiles.isEmpty) return const LoginPage();

    // Load tokens from profile
    var profile = profiles.first;
    loadTokensFromPayload(jsonDecode(profile.value));

    String session = getSessionFromJWT(sessionToken);

    // Refresh token
    final body = await postJSON("/auth/refresh", <String, dynamic>{
      "session": session,
      "token": refreshToken,
    });

    sendLog(body);

    // Set new token (if refreshed)
    if (body["success"]) {
      loadTokensFromPayload(body);
      await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "profile", value: tokensToPayload()));
    } else {
      if (body["error"] == "session.duration") {
        return null;
      }

      if (body["code"] != null && body["code"] != 200) {
        return const LoginPage();
      }

      if (body["error"] == "server.error") {
        return const ErrorPage(title: "server.error");
      }

      return const LoginPage();
    }

    return null;
  }
}
