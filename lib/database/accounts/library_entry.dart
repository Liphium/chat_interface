import 'package:drift/drift.dart';

class LibraryEntry extends Table {
  IntColumn get type => intEnum<LibraryEntryType>()();
  Int64Column get createdAt => int64()();
  TextColumn get data => text()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
}

enum LibraryEntryType { attachment, remote }
