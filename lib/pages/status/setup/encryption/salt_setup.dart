import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';

late String encryptionSalt;

class SaltSetup extends Setup {
  SaltSetup() : super("setup.salt", true);

  @override
  Future<Widget?> load() async {
    
    final salt = await (db.select(db.setting)..where((tbl) => tbl.key.equals("salt"))).getSingleOrNull();

    if(salt == null) {
      encryptionSalt = SecureRandom(8).base64.substring(0, 8);
      await db.into(db.setting).insert(SettingCompanion.insert(key: "salt", value: encryptionSalt));
    } else {
      encryptionSalt = salt.value;
    }

    return null;
  }
}