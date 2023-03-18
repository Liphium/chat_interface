import 'dart:convert';

import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/widgets.dart';
import 'package:pointycastle/export.dart';

import '../setup_manager.dart';

late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> asymmetricKeyPair;

class KeySetup extends Setup {
  KeySetup() : super("loading.keys", false);

  @override
  Future<Widget?> load() async {

    var privateKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("private_key"))).getSingleOrNull();
    var publicKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("public_key"))).getSingleOrNull();

    if(privateKey == null) {

      final pair = generateRSAKey();
      final packagedPriv = packagePrivateKey(pair.privateKey);
      final packagedPub = packagePublicKey(pair.publicKey);

      // Insert into database
      await db.into(db.setting).insert(SettingCompanion.insert(key: "private_key", value: packagedPriv));
      await db.into(db.setting).insert(SettingCompanion.insert(key: "public_key", value: packagedPub));

      // Set on the server
      await postRqAuthorized("/account/keys/public/set", <String, dynamic>{
        "key": packagedPub
      });

      privateKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("private_key"))).getSingleOrNull();
      publicKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("public_key"))).getSingleOrNull();

    } else {

      // Verify keys
      final res = await postRqAuthorized("/account/keys/public/get", <String, dynamic>{});
      if(res.statusCode != 200) {
        return const ErrorPage(title: "key.error");
      }

      final body = jsonDecode(res.body);

      if(!body["success"]) {
        return const ErrorPage(title: "key.error");
      }

      if(body["key"] != publicKey!.value) {
        return const ErrorPage(title: "key.invalid");
      }

    }

    asymmetricKeyPair = toKeyPair(privateKey!.value, publicKey!.value);

    return null;
  }
}