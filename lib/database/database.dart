
import 'package:chat_interface/database/accounts/setting.dart';
import 'package:drift/drift.dart';

import 'accounts/friend.dart';
import 'conversation/conversation.dart';
import 'conversation/message.dart';

part 'database.g.dart';

bool databaseInitialized = false;
late Database db;

@DriftDatabase(tables: [Conversation, Member, Message, Setting, Friend])
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}