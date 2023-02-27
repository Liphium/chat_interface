import 'package:drift/drift.dart';

class Conversation extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();

}

class Member extends Table {
  
    TextColumn get name => text()();
    IntColumn get conversationId => integer().nullable().customConstraint('REFERENCES conversations(id)')();
    IntColumn get accountId => integer()();

    // 1 - member, 2 - admin, 3 - owner
    IntColumn get roleId => integer()();
}