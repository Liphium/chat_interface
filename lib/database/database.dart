import 'package:chat_interface/database/database.steps.dart';
import 'package:chat_interface/database/database_entities.dart';
import 'package:chat_interface/database/trusted_links.dart';
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: stepByStep(
        from1To2: (m, schema) async {
          m.createTable(schema.message);
        },
      ),
    );
  }
}
