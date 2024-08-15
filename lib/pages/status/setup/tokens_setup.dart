import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

class TokensSetup extends Setup {
  TokensSetup() : super("loading.tokens", false);

  @override
  Future<Widget?> load() async {
    // Check if there are tokens for logging in
    final token = await (db.setting.select()..where((tbl) => tbl.key.equals("tokens"))).getSingleOrNull();
    if (token == null) {
      return const LoginPage();
    }

    return null;
  }
}
