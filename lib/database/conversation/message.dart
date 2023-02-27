import 'package:drift/drift.dart';

class Message extends Table {
  
    TextColumn get id => text()();
    TextColumn get content => text()();
    DateTimeColumn get createdAt => dateTime()();
    IntColumn get conversationId => integer().nullable().customConstraint('REFERENCES conversations(id)')();
}