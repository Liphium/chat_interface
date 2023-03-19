import 'dart:convert';

import 'package:chat_interface/pages/status/setup/account/key_setup.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';

import '../../../util/web.dart';

void login(String email, String password, {Function()? success, Function(String)? failure}) async {

  // Encrypt to protect password
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);

  keyPass = digest.toString();
  keyPassRaw = password;

  Response res;
  try {
    res = await postRq("/auth/login", <String, String>{
      "email": email,
      "password": digest.toString(),
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