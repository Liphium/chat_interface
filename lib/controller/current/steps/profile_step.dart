import 'dart:convert';

import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';

class ProfileSetup extends ConnectionStep {
  ProfileSetup() : super('loading.profile');

  @override
  Future<SetupResponse> load() async {
    // Check if the user has logged in already
    final profile = await retrieveEncryptedValue("tokens");
    if (profile == null) {
      return SetupResponse(restart: true);
    }

    // Load tokens from profile
    loadTokensFromPayload(jsonDecode(profile));

    // Get the session id from the JWT token
    String session = getSessionFromJWT(sessionToken);

    // Refresh token
    final body = await postJSON("/account/auth/refresh", <String, dynamic>{
      "session": session,
      "token": refreshToken,
    });

    // Set new token (if refreshed)
    if (body["success"]) {
      loadTokensFromPayload(body);
      await setEncryptedValue("tokens", tokensToPayload());
    } else {
      // Check if the status code isn't 200 (set by the _postTCP method)
      if (body["code"] != null && body["code"] != 200) {
        return SetupResponse(error: "server.error");
      }

      // Check if the session is not verified
      if (body["verified"] != null && !body["verified"]) {
        final res = await KeySetup.openKeySynchronization();
        return SetupResponse(
          retryConnection: true,
          error: res,
        );
      }

      // Check if the account data is invalid (make sure to delete everything)
      if (body["valid"] != null && !body["valid"]) {
        await db.setting.deleteWhere((tbl) => tbl.key.equals("tokens"));
        return SetupResponse(restart: true);
      }

      // Just return the error
      return SetupResponse(error: body["error"]);
    }

    return SetupResponse();
  }
}
