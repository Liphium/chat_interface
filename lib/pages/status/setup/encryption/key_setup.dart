import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/widgets.dart';
import 'package:sodium_libs/sodium_libs.dart';

import '../setup_manager.dart';

late SecureKey profileKey;
late KeyPair asymmetricKeyPair;

class KeySetup extends Setup {
  KeySetup() : super("loading.keys", false);

  @override
  Future<Widget?> load() async {

    // Get keys from the server
    final publicRes = await postRqAuthorized("/account/keys/public/get", <String, dynamic>{});

    if(publicRes.statusCode != 200) {
      return const ErrorPage(title: "key.error");
    }

    final pubBody = jsonDecode(publicRes.body);
    var privateKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("private_key"))).getSingleOrNull();

    if(!pubBody["success"]) {

      final pair = generateAsymmetricKeyPair();

      final packagedPriv = packagePrivateKey(pair.secretKey);
      final packagedPub = packagePublicKey(pair.publicKey);
      final genProfileKey = randomSymmetricKey();

      // Set public key on the server
      var res = await postRqAuthorized("/account/keys/public/set", <String, dynamic>{
        "key": packagedPub
      });

      if(res.statusCode != 200 || !jsonDecode(res.body)["success"]) {
        return const ErrorPage(title: "key.error");
      }

      res = await postRqAuthorized("/account/keys/profile/set", <String, dynamic>{
        "key": encryptAsymmetricAnonymous(pair.publicKey, packageSymmetricKey(genProfileKey))
      });

      if(res.statusCode != 200 || !jsonDecode(res.body)["success"]) {
        return const ErrorPage(title: "key.error");
      }

      // Insert private key into the database
      privateKey = SettingData(key: "private_key", value: packagedPriv);
      await db.into(db.setting).insertOnConflictUpdate(privateKey);
      pubBody["key"] = packagedPub;

    } else {

      if(privateKey == null) {
        return const ErrorPage(title: "priv.error");
      }

    }

    // Grab profile key from server
    final res = await postRqAuthorized("/account/keys/profile/get", <String, dynamic>{});

    if(res.statusCode != 200) {
      return const ErrorPage(title: "key.error");
    }

    final json = jsonDecode(res.body);
    if(!json["success"]) {
      return const ErrorPage(title: "key.error");
    }

    profileKey = unpackageSymmetricKey(decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, json["key"]));
    asymmetricKeyPair = toKeyPair(pubBody["key"], privateKey.value);

    return null;
  }
}