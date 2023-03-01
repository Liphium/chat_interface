import 'dart:convert';

import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

class ProfileSetup extends Setup {
  ProfileSetup() : super('loading.profile', const LoginPage());
  
  @override
  Future<bool> load() async {

    // Get profile from database
    var profiles = await (db.select(db.setting)..where((tbl) => tbl.key.equals("profile"))).get();
    if(profiles.isEmpty) return false;

    // Load tokens from profile
    var profile = profiles.first;
    loadTokensFromPayload(jsonDecode(profile.value));

    // Refresh token
    var res = await postRq("/auth/refresh", <String, dynamic>{
      "token": refreshToken,
    });

    if(res.statusCode != 200) return false;

    // Set new token (if refreshed)
    var body = jsonDecode(res.body);
    if(body["success"]) {
      loadTokensFromPayload(body);
    } else {

      if(body["error"].equals("session.duration")) {
        return true;
      }

      Get.snackbar("loading.profile".tr, body["error"].tr);
      return false;
    }

    return true;
  }
}