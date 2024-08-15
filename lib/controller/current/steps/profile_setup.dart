import 'dart:convert';

import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/steps/key_setup.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/util/web.dart';

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
    final body = await postJSON("/auth/refresh", <String, dynamic>{
      "session": session,
      "token": refreshToken,
    });

    // Set new token (if refreshed)
    if (body["success"]) {
      loadTokensFromPayload(body);
      await setEncryptedValue("tokens", tokensToPayload());
    } else {
      // Check if the session is not verified
      if (body["error"] == "session.not_verified") {
        final res = await KeySetup.openKeySynchronization();
        return SetupResponse(
          retryConnection: true,
          error: res,
        );
      }

      // Check if the error says that the token can't be refreshed, but is still valid
      if (body["error"] == "session.duration") {
        return SetupResponse();
      }

      // Check if the status code isn't 200 (set by the _postTCP method)
      if (body["code"] != null && body["code"] != 200) {
        return SetupResponse(retryConnection: true);
      }

      // Check if there was an issue on the server
      if (body["error"] == "server.error") {
        return SetupResponse(error: "server.error");
      }

      // Check if the server's protocol isn't compatable
      if (body["error"] == "protocol.error") {
        return SetupResponse(error: "protocol.error");
      }

      return SetupResponse(error: body["error"]);
    }

    return SetupResponse();
  }
}
