import 'dart:convert';

import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/main.dart';
import 'package:http/http.dart';

import '../../../util/web.dart';

void loginStart(String email, {Function()? success, Function(String)? failure}) async {

  Response res;
  try {
    res = await postRq("/auth/login/start", <String, String>{
      "email": email,
      "device": "desktop" // Let user enter this
    });
  } catch (e) {
    failure?.call("error.network");
    return;
  }

  if(res.statusCode != 200) {
    failure?.call("server.error");
    return;
  }

  var body = jsonDecode(res.body);

  if(!body["success"]) {
    failure?.call(body["error"]);
    return;
  }

  loadTokensFromPayload(body);
  success?.call();
}

void loginStep(String token, String secret, AuthType type, {Function()? success, Function(String)? failure}) {

  secret = _transformForAuth(secret, type);

}

String _transformForAuth(String secret, AuthType type) {
  switch(type) {
    case AuthType.password:
      return hashSha(secret);
    case AuthType.totp:
      return secret;
    case AuthType.recoveryCode:
      return secret;
    case AuthType.passkey:
      return secret;
    default:
      return secret;
  }
}