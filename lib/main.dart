import 'dart:io';

import 'package:chat_interface/controller/controller_manager.dart';
import 'package:chat_interface/database/database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'app.dart';

var logger = Logger();
const appId = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final dbFolder = await getApplicationSupportDirectory();
  logger.i(dbFolder.path);
  final file = File(path.join(dbFolder.path, 'chat.db'));
  db = Database(NativeDatabase.createInBackground(file, logStatements: true));

  // Create tables
  var _ = await (db.select(db.setting)).get();

  // Initialize controllers
  initializeControllers();

  runApp(const ChatApp());
}

