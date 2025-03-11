import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:drift/drift.dart';

enum ConversationType { directMessage, group }

@TableIndex(name: "idx_conversation_updated", columns: {#updatedAt})
class Conversation extends Table {
  TextColumn get id => text()();
  TextColumn get vaultId => text()();
  IntColumn get type => intEnum<ConversationType>()();
  TextColumn get data => text()();
  TextColumn get token => text()();
  TextColumn get key => text()();
  Int64Column get lastVersion => int64()();
  Int64Column get updatedAt => int64()();
  Int64Column get readAt => int64()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@TableIndex(name: "idx_message_created", columns: {#createdAt})
class Message extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  TextColumn get senderToken => text()();
  TextColumn get senderAddress => text()();
  Int64Column get createdAt => int64()();
  TextColumn get conversation => text()();
  BoolColumn get edited => boolean()();
  BoolColumn get verified => boolean()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Member extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text().nullable()();
  TextColumn get accountId => text()();

  // 1 - member, 2 - admin, 3 - owner
  IntColumn get roleId => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@TableIndex(name: "idx_friends_updated", columns: {#updatedAt})
class Friend extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get displayName => text()();
  TextColumn get vaultId => text()();
  TextColumn get keys => text()();
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
  TextColumn get data => text()();
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
  TextColumn get pictureContainer => text()();

  TextColumn get data => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: "idx_requests_updated", columns: {#updatedAt})
class Request extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get displayName => text()();
  BoolColumn get self => boolean()(); // Whether the request is sent by the current user
  TextColumn get vaultId => text()();
  TextColumn get keys => text()();
  Int64Column get updatedAt => int64()();

  @override
  Set<Column> get primaryKey => {id};
}

class Setting extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>>? get primaryKey => {key};
}

@TableIndex(name: "idx_unknown_profiles_last_fetched", columns: {#lastFetched})
class UnknownProfile extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get displayName => text()();
  TextColumn get keys => text()();
  DateTimeColumn get lastFetched => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
