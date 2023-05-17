import 'package:drift/drift.dart';

class Conversation extends Table {

  TextColumn get id => text()();
  TextColumn get data => text().nullable()();
  TextColumn get key => text().nullable()();
  Int64Column get updatedAt => int64()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Member extends Table {
  
    TextColumn get id => text()();
    TextColumn get name => text()();
    TextColumn get conversationId => text().nullable()();
    TextColumn get accountId => text()();

    // 1 - member, 2 - admin, 3 - owner
    IntColumn get roleId => integer()();

    @override
    Set<Column<Object>>? get primaryKey => {id};
}