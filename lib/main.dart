import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/database/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'app.dart';

var logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = Database(NativeDatabase.memory(logStatements: true));

  for (int i = 0; i < 10; i++) {
    await db.into(db.message).insert(MessageCompanion.insert(
      id: i.toRadixString(32),
      content: 'Hello $i times.',
      createdAt: DateTime.now(),
      conversationId: const Value(1),
    ));
  }

  (await db.select(db.message).get()).forEach(logger.i);

  runApp(const ChatApp());
}

