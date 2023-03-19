import 'package:drift/drift.dart';

class Conversation extends Table {

  IntColumn get id => integer()();
  TextColumn get data => text()();
  TextColumn get key => text()();
  Int64Column get updatedAt => int64()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Member extends Table {
  
    IntColumn get id => integer()();
    TextColumn get name => text()();
    IntColumn get conversationId => integer().nullable().customConstraint('REFERENCES conversations(id)')();
    IntColumn get accountId => integer()();

    // 1 - member, 2 - admin, 3 - owner
    IntColumn get roleId => integer()();

    @override
    Set<Column<Object>>? get primaryKey => {id};
}