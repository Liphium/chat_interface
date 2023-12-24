import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/error/error_page.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/widgets.dart';
import 'package:pointycastle/export.dart';
import 'package:sodium_libs/sodium_libs.dart';

import '../setup_manager.dart';

late SecureKey profileKey;
late KeyPair asymmetricKeyPair;
late KeyPair signatureKeyPair;
late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> rsaKeyPair;

class KeySetup extends Setup {
  KeySetup() : super("loading.keys", false);

  @override
  Future<Widget?> load() async {

    // Generate RSA key pair
    rsaKeyPair = generateRSAKey(standardKeySize);

    // Get keys from the server
    final pubBody = await postAuthorizedJSON("/account/keys/public/get", <String, dynamic>{});
    var privateKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("private_key"))).getSingleOrNull();

    if(!pubBody["success"]) {

      final signatureKeyPair = generateSignatureKeyPair();
      final pair = generateAsymmetricKeyPair();

      final packagedSignaturePriv = packagePrivateKey(signatureKeyPair.secretKey);
      final packagedSignaturePub = packagePublicKey(signatureKeyPair.publicKey);
      final packagedPriv = packagePrivateKey(pair.secretKey);
      final packagedPub = packagePublicKey(pair.publicKey);
      final genProfileKey = randomSymmetricKey();

      // Set public key on the server
      var res = await postAuthorizedJSON("/account/keys/public/set", <String, dynamic>{
        "key": packagedPub
      });
      if(!res["success"]) {
        return const ErrorPage(title: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/profile/set", <String, dynamic>{
        "key": encryptAsymmetricAnonymous(pair.publicKey, packageSymmetricKey(genProfileKey))
      });
      if(!res["success"]) {
        return const ErrorPage(title: "key.error");
      }
      res = await postAuthorizedJSON("/account/keys/signature/set", <String, dynamic>{
        "key": packagedSignaturePub
      });
      if(!res["success"]) {
        return const ErrorPage(title: "key.error");
      }

      // Insert private key into the database
      privateKey = SettingData(key: "private_key", value: packagedPriv);
      await db.into(db.setting).insertOnConflictUpdate(privateKey);
      await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "public_key", value: packagedPub));
      pubBody["key"] = packagedPub;
      final signaturePrivateKey = SettingData(key: "signature_private_key", value: packagedSignaturePriv);
      await db.into(db.setting).insertOnConflictUpdate(signaturePrivateKey);
      await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "signature_public_key", value: packagedSignaturePub));

    } else {

      if(privateKey == null) {
        return const ErrorPage(title: "priv.error");
      }

    }

    // Grab profile key from server
    final json = await postAuthorizedJSON("/account/keys/profile/get", <String, dynamic>{});
    if(!json["success"]) {
      return const ErrorPage(title: "key.error");
    }

    asymmetricKeyPair = toKeyPair(pubBody["key"], privateKey.value);
    profileKey = unpackageSymmetricKey(decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, json["key"]));

    // Grab signature key from client database
    final signaturePrivateKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("signature_private_key"))).getSingleOrNull();
    final signaturePublicKey = await (db.select(db.setting)..where((tbl) => tbl.key.equals("signature_public_key"))).getSingleOrNull();
    if(signaturePrivateKey == null || signaturePublicKey == null) {
      return const ErrorPage(title: "key.error");
    }

    signatureKeyPair = toKeyPair(signaturePublicKey.value, signaturePrivateKey.value);

    return null;
  }
}