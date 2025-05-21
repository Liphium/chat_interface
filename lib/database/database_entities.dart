import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:drift/drift.dart';

enum ConversationType { directMessage, group, square }

@TableIndex(name: "idx_conversation_updated", columns: {#updatedAt})
class Conversation extends Table {
  TextColumn get id => text()();
  BlobColumn get vaultId => blob()();
  IntColumn get type => intEnum<ConversationType>()();
  BlobColumn get data => blob()();
  BlobColumn get members => blob()();
  BlobColumn get token => blob()();
  BlobColumn get key => blob()();
  Int64Column get lastVersion => int64()();
  Int64Column get updatedAt => int64()();
  BlobColumn get reads => blob()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@TableIndex(name: "idx_message_created", columns: {#createdAt})
class Message extends Table {
  TextColumn get id => text()();
  BlobColumn get content => blob()();
  TextColumn get senderToken => text()();
  BlobColumn get senderAddress => blob()();
  Int64Column get createdAt => int64()();
  TextColumn get conversation => text()();
  BoolColumn get edited => boolean()();
  BoolColumn get verified => boolean()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@TableIndex(name: "idx_friends_updated", columns: {#updatedAt})
class Friend extends Table {
  TextColumn get id => text()();
  BlobColumn get name => blob()();
  BlobColumn get displayName => blob()();
  BlobColumn get vaultId => blob()();
  BlobColumn get keys => blob()();
  Int64Column get updatedAt => int64()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "idx_library_entry_created", columns: {#createdAt})
@TableIndex(name: "idx_library_entry_idhash", columns: {#identifierHash})
class LibraryEntry extends Table {
  TextColumn get id => text()();
  IntColumn get type => intEnum<LibraryEntryType>()();
  Int64Column get createdAt => int64()();
  TextColumn get identifierHash => text().withDefault(Constant("to-migrate"))();
  BlobColumn get data => blob()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
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

class Profile extends Table {
  TextColumn get id => text()();

  // Profile picture data
  BlobColumn get pictureContainer => blob().nullable()();

  BlobColumn get data => blob().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "idx_requests_updated", columns: {#updatedAt})
class Request extends Table {
  TextColumn get id => text()();
  BlobColumn get name => blob()();
  BlobColumn get displayName => blob()();
  BoolColumn get self => boolean()(); // Whether the request is sent by the current user
  BlobColumn get vaultId => blob()();
  BlobColumn get keys => blob()();
  Int64Column get updatedAt => int64()();

  @override
  Set<Column> get primaryKey => {id};
}

class Setting extends Table {
  TextColumn get key => text()();
  BlobColumn get value => blob()();

  @override
  Set<Column<Object>>? get primaryKey => {key};
}

@TableIndex(name: "idx_unknown_profiles_last_fetched", columns: {#lastFetched})
class UnknownProfile extends Table {
  TextColumn get id => text()();
  BlobColumn get name => blob()();
  BlobColumn get displayName => blob()();
  BlobColumn get keys => blob()();
  DateTimeColumn get lastFetched => dateTime().withDefault(Constant(DateTime.fromMillisecondsSinceEpoch(0)))();

  @override
  Set<Column> get primaryKey => {id};
}
