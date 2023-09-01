import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';

part 'vault_actions.dart';

class VaultSetup extends Setup {

  VaultSetup() : super("loading.vault", false);

  @override
  Future<Widget?> load() async {
    
    final json = await postAuthorizedJSON("/account/vault/list", <String, dynamic>{});
    if(!json["success"]) {
      return ErrorPage(title: json["error"]);
    }

    for(var entry in json["entries"]) {
      print(entry);
    }

    return null;
  }

}