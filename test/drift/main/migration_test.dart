// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations.dart';
import 'package:chat_interface/database/database.dart';
import 'package:test/test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    final versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = Database(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Simple tests ensure the schema is transformed correctly, but some
  // migrations benefit from a test verifying that data is transformed correctly
  // too. This is particularly true for migrations that change existing columns
  // (e.g. altering their type or constraints). Migrations that only add tables
  // or columns typically don't need these advanced tests.
  // TODO: Check whether you have migrations that could benefit from these tests
  // and adapt this example to your database if necessary:
  test("migration from v1 to v2 does not corrupt data", () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    final oldConversationData = <v1.ConversationData>[];
    final expectedNewConversationData = <v2.ConversationData>[];

    final oldMemberData = <v1.MemberData>[];
    final expectedNewMemberData = <v2.MemberData>[];

    final oldSettingData = <v1.SettingData>[];
    final expectedNewSettingData = <v2.SettingData>[];

    final oldFriendData = <v1.FriendData>[];
    final expectedNewFriendData = <v2.FriendData>[];

    final oldRequestData = <v1.RequestData>[];
    final expectedNewRequestData = <v2.RequestData>[];

    final oldUnknownProfileData = <v1.UnknownProfileData>[];
    final expectedNewUnknownProfileData = <v2.UnknownProfileData>[];

    final oldProfileData = <v1.ProfileData>[];
    final expectedNewProfileData = <v2.ProfileData>[];

    final oldTrustedLinkData = <v1.TrustedLinkData>[];
    final expectedNewTrustedLinkData = <v2.TrustedLinkData>[];

    final oldLibraryEntryData = <v1.LibraryEntryData>[];
    final expectedNewLibraryEntryData = <v2.LibraryEntryData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: Database.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.conversation, oldConversationData);
        batch.insertAll(oldDb.member, oldMemberData);
        batch.insertAll(oldDb.setting, oldSettingData);
        batch.insertAll(oldDb.friend, oldFriendData);
        batch.insertAll(oldDb.request, oldRequestData);
        batch.insertAll(oldDb.unknownProfile, oldUnknownProfileData);
        batch.insertAll(oldDb.profile, oldProfileData);
        batch.insertAll(oldDb.trustedLink, oldTrustedLinkData);
        batch.insertAll(oldDb.libraryEntry, oldLibraryEntryData);
      },
      validateItems: (newDb) async {
        expect(expectedNewConversationData, await newDb.select(newDb.conversation).get());
        expect(expectedNewMemberData, await newDb.select(newDb.member).get());
        expect(expectedNewSettingData, await newDb.select(newDb.setting).get());
        expect(expectedNewFriendData, await newDb.select(newDb.friend).get());
        expect(expectedNewRequestData, await newDb.select(newDb.request).get());
        expect(expectedNewUnknownProfileData, await newDb.select(newDb.unknownProfile).get());
        expect(expectedNewProfileData, await newDb.select(newDb.profile).get());
        expect(expectedNewTrustedLinkData, await newDb.select(newDb.trustedLink).get());
        expect(expectedNewLibraryEntryData, await newDb.select(newDb.libraryEntry).get());
      },
    );
  });
}
