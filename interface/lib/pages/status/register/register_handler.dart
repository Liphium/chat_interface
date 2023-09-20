import 'dart:convert';

import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:http/http.dart';

import '../../../util/web.dart';

void register(String email, String username, String tag, String password, {Function()? success, Function(String)? failure}) async {

  Response res;
  try {
    res = await postRq("/auth/register", <String, String>{
      "email": email,
      "password": hashSha(password),
      "username": username,
      "tag": tag,
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

  success?.call();
}