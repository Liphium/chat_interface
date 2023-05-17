import 'package:drift/drift.dart';

class Message extends Table {
  
  TextColumn get id => text()();
  BoolColumn get verified => boolean()();
  TextColumn get type => text()();
  TextColumn get content => text()();
  TextColumn get attachments => text()();
  TextColumn get certificate => text()();
  TextColumn get sender => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get conversationId => text().nullable()();
  BoolColumn get edited => boolean()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}