import 'package:drift/drift.dart';

enum ConversationType {
  directMessage,
  group
}

class Conversation extends Table {

  TextColumn get id => text()();
  IntColumn get type => intEnum<ConversationType>()();
  TextColumn get data => text()();
  TextColumn get token => text()();
  TextColumn get key => text()();
  Int64Column get updatedAt => int64()();
  Int64Column get readAt => int64()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Member extends Table {
  
    TextColumn get id => text()();
    TextColumn get conversationId => text().nullable()();
    TextColumn get accountId => text()();

    // 1 - member, 2 - admin, 3 - owner
    IntColumn get roleId => integer()();

    @override
    Set<Column<Object>>? get primaryKey => {id};
}