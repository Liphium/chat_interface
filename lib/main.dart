import 'package:chat_interface/controller/controller_manager.dart';
import 'package:chat_interface/database/database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'app.dart';

var logger = Logger();
const appId = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  db = Database(NativeDatabase.memory(logStatements: true));

  // Create tables
  var _ = await (db.select(db.setting)).get();

  // Initialize controllers
  initializeControllers();

  runApp(const ChatApp());
}

