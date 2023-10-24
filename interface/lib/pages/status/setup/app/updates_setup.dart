import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';


class UpdateSetup extends Setup {
  UpdateSetup() : super('loading.update', false);
  
  @override
  Future<Widget?> load() async {

    if(!checkVersion) {
      return null;
    }

    // TODO: Update the actual app files from some source
    final json = await postJSON("/app/version", <String, dynamic>{
      "app": appId
    });

    if(!json["success"]) {
      return const ErrorPage(title: "server.error");
    }

    if(json["version"] != appVersion) {
      return const ErrorPage(title: "new.version");
    }

    return null;
  }
}