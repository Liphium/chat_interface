import 'package:chat_interface/connection/encryption/hash.dart';

import '../../../util/web.dart';

void register(String invite, String email, String username, String tag, String password, {Function()? success, Function(String)? failure}) async {
  var body = await postJSON("/auth/register", <String, String>{
    "invite": invite,
    "email": email,
    "password": hashSha(password),
    "username": username,
    "tag": tag,
  });

  if (!body["success"]) {
    failure?.call(body["error"]);
    return;
  }

  success?.call();
}
