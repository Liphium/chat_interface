import 'package:chat_interface/controller/controller_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as log;
import 'package:logging/logging.dart';

import 'app.dart';

var logger = log.Logger();
const appId = 0;
const bool isDebug = true;

void main() async {

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((event) {
    logger.d(event.message);
  });

  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controllers
  initializeControllers();

  runApp(const ChatApp());
}

