
import 'package:drift/drift.dart';

import 'conversation/conversation.dart';
import 'conversation/message.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Conversation, Member, Message])
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}