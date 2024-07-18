import 'dart:convert';

import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/setup/account/key_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';

class ProfileSetup extends Setup {
  ProfileSetup() : super('loading.profile', false);

  @override
  Future<Widget?> load() async {
    // Check if the user has logged in already
    final profile = await (db.select(db.setting)..where((tbl) => tbl.key.equals("tokens"))).getSingleOrNull();
    if (profile == null) return const LoginPage();

    // Load tokens from profile
    loadTokensFromPayload(jsonDecode(profile.value));

    // Get the session id from the JWT token
    String session = getSessionFromJWT(sessionToken);

    // Refresh token
    final body = await postJSON("/auth/refresh", <String, dynamic>{
      "session": session,
      "token": refreshToken,
    });

    // Set new token (if refreshed)
    if (body["success"]) {
      loadTokensFromPayload(body);
      await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "tokens", value: tokensToPayload()));
    } else {
      // Check if the session is not verified
      if (body["error"] == "session.not_verified") {
        return await KeySetup.openKeySynchronization();
      }

      // Check if the error says that the token can't be refreshed, but is still valid
      if (body["error"] == "session.duration") {
        return null;
      }

      // Check if the status code isn't 200 (set by the _postTCP method)
      if (body["code"] != null && body["code"] != 200) {
        return const LoginPage();
      }

      // Check if there was an issue on the server
      if (body["error"] == "server.error") {
        return const ErrorPage(title: "server.error");
      }

      // Check if the server's protocol isn't compatable
      if (body["error"] == "protocol.error") {
        return const ErrorPage(title: "protocol.error");
      }

      return const LoginPage();
    }

    return null;
  }
}
