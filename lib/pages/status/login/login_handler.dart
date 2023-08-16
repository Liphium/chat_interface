

import 'dart:convert';

import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/login/login_choose_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart' as g;
import 'package:http/http.dart';

import 'login_step_page.dart';

void loginStart(String email, {Function()? success, Function(String)? failure}) async {

  Response res;
  try {
    res = await postRq("/auth/login/start", <String, String>{
      "email": email,
      "device": "desktop" // TODO: Let user enter this
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
  final methods = body["methods"] as List<dynamic>;
  if(methods.length == 1) {
    g.Get.find<TransitionController>().modelTransition(LoginStepPage(AuthType.fromId(methods[0] as int), body["token"]));
    return;
  }

  g.Get.find<TransitionController>().modelTransition(LoginChoosePage(methods.map((e) => AuthType.fromId(e as int)).toList(), body["token"]));
}

void loginStep(String token, String secret, AuthType type, {Function()? success, Function(String)? failure}) async {

  secret = _transformForAuth(secret, type);

  Response res;
  try {
    res = await postRqAuth("/auth/login/step", <String, dynamic>{
      "type": type.id,
      "secret": secret
    }, token);
  } catch (e) {
    failure?.call("error.network");
    return;
  }

  if(res.statusCode != 200) {
    failure?.call("server.error");
    return;
  }

  var body = jsonDecode(res.body) as Map<String, dynamic>;

  if(!body["success"]) {
    failure?.call(body["error"]);
    return;
  }

  if(body.containsKey("refresh_token")) {
    loadTokensFromPayload(body);
    await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "profile", value: tokensToPayload()));
    success?.call();
    setupManager.next(open: true);
    return;
  }

  success?.call();
  final methods = body["methods"] as List<dynamic>;
  if(methods.length == 1) {
    g.Get.find<TransitionController>().modelTransition(LoginStepPage(AuthType.fromId(methods[0] as int), body["token"]));
    return;
  }

  g.Get.find<TransitionController>().modelTransition(LoginChoosePage(methods.map((e) => AuthType.fromId(e as int)).toList(), body["token"]));
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