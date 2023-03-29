import 'package:drift/drift.dart';

class Message extends Table {
  
  TextColumn get id => text()();
  BoolColumn get verified => boolean()();
  TextColumn get type => text()();
  TextColumn get content => text()();
  TextColumn get attachments => text()();
  TextColumn get certificate => text()();
  IntColumn get sender => integer().nullable().customConstraint('REFERENCES friends(id)')();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get conversationId => integer().nullable().customConstraint('REFERENCES conversations(id)')();
  BoolColumn get edited => boolean()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}