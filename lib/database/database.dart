import 'package:chat_interface/database/database.steps.dart';
import 'package:chat_interface/database/database_entities.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:drift/drift.dart';

part 'database.g.dart';

bool databaseInitialized = false;
late Database db;

@DriftDatabase(tables: [
  Conversation,
  Message,
  Member,
  Setting,
  Friend,
  Request,
  UnknownProfile,
  Profile,
  TrustedLink,
  LibraryEntry,
])
class Database extends _$Database {
  Database(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: stepByStep(
        from1To2: (m, schema) async {
          await m.createTable(schema.message);
        },
        from2To3: (m, schema) async {
          // Add indexes to some tables for improved performance
          await m.createIndex(schema.idxConversationUpdated);
          await m.createIndex(schema.idxFriendsUpdated);
          await m.createIndex(schema.idxLibraryEntryCreated);
          await m.createIndex(schema.idxMessageCreated);
        },
      ),
    );
  }
}
