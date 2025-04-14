import 'package:chat_interface/database/database.dart';
import 'package:drift/drift.dart';

class VaultVersioningService {
  // All vault types
  static const vaultTypeFriend = "fr";
  static const vaultTypeGeneral = "gn";

  /// Store or update new version for a type of vault and tag.
  static Future<void> storeOrUpdateVersion(String type, String tag, int version) async {
    await db.setting.insertOnConflictUpdate(
      SettingData(key: "$type:$tag:version", value: version.toString()),
    );
  }

  /// Get the version for a type and tag.
  static Future<int> retrieveVersion(String type, String tag) async {
    final result =
        await (db.setting.select()..where((tbl) => tbl.key.equals("$type:$tag:version")))
            .getSingleOrNull();
    return int.parse(result?.value ?? "0");
  }
}
