import 'package:chat_interface/controller/controller_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'app.dart';

var logger = Logger();
const appId = 0;
const bool isDebug = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  initializeControllers();

  runApp(const ChatApp());
}

