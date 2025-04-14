import 'package:chat_interface/database/database.steps.dart';
import 'package:chat_interface/database/database_entities.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:drift/drift.dart';

part 'database.g.dart';

bool databaseInitialized = false;
late Database db;

@DriftDatabase(
  tables: [
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
  ],
)
class Database extends _$Database {
  Database(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: stepByStep(
        from1To2: (m, schema) async {
          // Add new table for local message storage
          await m.createTable(schema.message);
        },
        from2To3: (m, schema) async {
          // Add indexes to some tables for improved performance
          await m.createIndex(schema.idxConversationUpdated);
          await m.createIndex(schema.idxFriendsUpdated);
          await m.createIndex(schema.idxLibraryEntryCreated);
          await m.createIndex(schema.idxMessageCreated);
        },
        from3To4: (m, schema) async {
          // Create a new column for a hashed identifier of the library entry (so the file container can be encrypted)
          await m.addColumn(schema.libraryEntry, schema.libraryEntry.identifierHash);

          // Create a new column for a unknown profile's last cache (it's now no longer cached in memory)
          await m.addColumn(schema.unknownProfile, schema.unknownProfile.lastFetched);

          // Add indexes to improve performance (forgot some during initial additions)
          await m.createIndex(schema.idxUnknownProfilesLastFetched);
          await m.createIndex(schema.idxLibraryEntryIdhash);
          await m.createIndex(schema.idxRequestsUpdated);
        },
      ),
    );
  }
}
