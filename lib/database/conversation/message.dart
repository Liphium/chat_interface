import 'package:drift/drift.dart';

class Message extends Table {
  
    TextColumn get id => text()();
    TextColumn get content => text()();
    IntColumn get sender => integer().nullable().customConstraint('REFERENCES friends(id)')();
    DateTimeColumn get createdAt => dateTime()();
    IntColumn get conversationId => integer().nullable().customConstraint('REFERENCES conversations(id)')();
    BoolColumn get edited => boolean()();
}