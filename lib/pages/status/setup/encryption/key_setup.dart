import 'dart:convert';

import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pointycastle/export.dart';

import '../setup_manager.dart';

late String keyPassRaw;
late String keyPass;
late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> asymmetricKeyPair;

class KeySetup extends Setup {
  KeySetup() : super("loading.keys", false);

  @override
  Future<Widget?> load() async {

    // Get keys from the server
    final publicRes = await postRqAuthorized("/account/keys/public/get", <String, dynamic>{});
    final salt = await (db.select(db.setting)..where((tbl) => tbl.key.equals("salt"))).getSingleOrNull();

    if(publicRes.statusCode != 200) {
      return const ErrorPage(title: "key.error");
    }

    final body = jsonDecode(publicRes.body);
    var privateKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("private_key"))).getSingleOrNull();

    StatusController controller = Get.find();

    if(!body["success"]) {

      final pair = await compute(generateRSAKey, 2048);

      final packagedPriv = packagePrivateKey(pair.privateKey);
      final encryptedPriv = encryptPrivateKey(pair.privateKey, keyPassRaw, controller.name.value, salt!.value);
      final packagedPub = packagePublicKey(pair.publicKey);

      // Set public key on the server
      var res = await postRqAuthorized("/account/keys/public/set", <String, dynamic>{
        "password": keyPass,
        "key": packagedPub
      });

      if(res.statusCode != 200 || !jsonDecode(res.body)["success"]) {
        return const ErrorPage(title: "key.error");
      }

      // Set private key on the server
      res = await postRqAuthorized("/account/keys/private/set", <String, dynamic>{
        "password": keyPass,
        "key": encryptedPriv
      });

      if(res.statusCode != 200 || !jsonDecode(res.body)["success"]) {
        return const ErrorPage(title: "key.error");
      }

      // Insert private key into the database
      privateKey = SettingData(key: "private_key", value: packagedPriv);
      await db.into(db.setting).insertOnConflictUpdate(privateKey);
      body["key"] = packagedPub;

    } else {

      if(privateKey == null) {
        return const ErrorPage(title: "priv.error");
      }

    }

    asymmetricKeyPair = toKeyPair(body["key"], privateKey.value);

    return null;
  }
}