import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:drift/drift.dart';

class LibraryEntry extends Table {
  IntColumn get type => intEnum<LibraryEntryType>()();
  Int64Column get createdAt => int64()();
  TextColumn get data => text()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
}

enum LibraryEntryType {
  image,
  gif;

  static LibraryEntryType fromFileName(String name) {
    for (var type in FileSettings.staticImageTypes) {
      if (name.endsWith(".$type")) {
        return LibraryEntryType.image;
      }
    }
    return LibraryEntryType.gif;
  }
}
