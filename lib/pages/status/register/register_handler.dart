import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';

import '../../../util/web.dart';

void register(String email, String username, String password, {Function()? success, Function(String)? failure}) async {

  // Encrypt to protect password
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);

  // Split username into tag and name
  var name = username.split("#")[0];
  var tag = username.split("#")[1];

  Response res;
  try {
    res = await postRq("/auth/register", <String, String>{
      "email": email,
      "password": digest.toString(),
      "username": name,
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