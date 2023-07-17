import 'package:chat_interface/controller/controller_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as log;

import 'app.dart';

var logger = log.Logger();
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

const liveKitURL = "wss://fj-chat-xc5qv7y8.livekit.cloud";

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controllers
  initializeControllers();

  runApp(const ChatApp());
}

