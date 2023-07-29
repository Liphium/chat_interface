
import 'package:chat_interface/controller/controller_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as log;
import 'package:sodium_libs/sodium_libs.dart';

import 'app.dart';

var logger = log.Logger();
late final Sodium sodium;
const appId = 0;
const bool isDebug = true;

// Authentication types
enum AuthType {
  password(0, "password"),
  totp(1, "totp"),
  recoveryCode(2, "recoveryCode"),
  passkey(3, "passkey");

  final int id;
  final String name;

  const AuthType(this.id, this.name);

  static AuthType fromId(int id) {
    return AuthType.values.firstWhere((element) => element.id == id);
  }
}

const liveKitURL = "";

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sodium
  sodium = await SodiumInit.init();
  
  // Initialize controllers
  initializeControllers();

  runApp(const ChatApp());
}

