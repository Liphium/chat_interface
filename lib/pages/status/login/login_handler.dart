import 'dart:convert';

import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:http/http.dart';

import '../../../util/web.dart';

void login(String email, String password, {Function()? success, Function(String)? failure}) async {

  // Hash to protect password
  keyPass = hashSha(password);
  keyPassRaw = password;

  Response res;
  try {
    res = await postRq("/auth/login", <String, String>{
      "email": email,
      "password": keyPass,
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