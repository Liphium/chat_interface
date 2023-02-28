
import 'package:chat_interface/database/accounts/setting.dart';
import 'package:drift/drift.dart';

import 'conversation/conversation.dart';
import 'conversation/message.dart';

part 'database.g.dart';

late Database db;

@DriftDatabase(tables: [Conversation, Member, Message, Setting])
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}