import 'dart:convert';

import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/src/rust/api/encryption.dart';
import 'package:chat_interface/util/encryption/packing.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';

class RecoveryTokenService {
  /// Generate a new recovery token.
  ///
  /// Returns the token (first) and an error (second) if there was one.
  static Future<(String?, String?)> generateNewToken() async {
    // Create the data sent to the server
    final key = await generateSymmetricKey();
    final data = await RecoveryKeyStorage(signatureKeyPair, asymmetricKeyPair).encrypted(key);

    // Generate a new token on the server
    final json = await postAuthorizedJSON("/account/keys/recovery/generate", {"data": data});
    if (!json["success"]) {
      return (null, json["error"] as String);
    }

    // Return the token based on the standard
    final packagedKey = await packageSymmetricKey(key);
    if (packagedKey == null) {
      return (null, "Failed to package symmetric key");
    }
    return ("${json["token"]}-$packagedKey", null);
  }

  /// Delete a recovery token using the token.
  ///
  /// Returns an error if there was one.
  static Future<String?> deleteToken(String token) async {
    // Send the requeat
    final json = await postAuthorizedJSON("/account/keys/recovery/delete", {"token": token.split("-")[0]});
    if (!json["success"]) {
      return json["error"];
    }

    return null;
  }
}

class RecoveryKeyStorage {
  final SignatureKeyPair signatureKeyPair;
  final AsymmetricKeyPair encryptionKeyPair;

  RecoveryKeyStorage(this.signatureKeyPair, this.encryptionKeyPair);

  /// Get [RecoveryKeyStorage] from the encrypted version sent to the server.
  static Future<RecoveryKeyStorage?> fromEncrypted(String encryptedData, String packagedSymmetricKey) async {
    final symmetricKey = await unpackageSymmetricKey(packagedSymmetricKey);
    if (symmetricKey == null) {
      sendLog("Error: Could not unpackage symmetric key for recovery.");
      return null;
    }

    // Decrypt the json and parse
    final decryptedBytes = await decryptSymmetric(key: symmetricKey, ciphertext: base64Decode(encryptedData));
    if (decryptedBytes == null) {
      sendLog("Error: Could not decrypt recovery data.");
      return null;
    }
    final data = jsonDecode(utf8.decode(decryptedBytes));

    // Unpackage all the keys to create the key storage
    final sigPub = await unpackageVerifyingKey(data['sig_ver']);
    final sigPriv = await unpackageSigningKey(data['sig_sig']);
    final encPub = await unpackagePublicKey(data['enc_pub']);
    final encPriv = await unpackageSecretKey(data['enc_sec']);

    if (sigPub == null || sigPriv == null || encPub == null || encPriv == null) {
      sendLog("Error: Failed to unpackage one or more keys from recovery data.");
      return null;
    }

    return RecoveryKeyStorage(
      SignatureKeyPair(verifyingKey: sigPub, signingKey: sigPriv),
      AsymmetricKeyPair(publicKey: encPub, secretKey: encPriv),
    );
  }

  /// Encrypt [RecoveryKeyStorage] in the form stored on the server.
  Future<String?> encrypted(SymmetricKey key) async {
    final sigVerifyPacked = await packageVerifyingKey(signatureKeyPair.verifyingKey);
    final sigSignPacked = await packageSigningKey(signatureKeyPair.signingKey);
    final encPubPacked = await packagePublicKey(encryptionKeyPair.publicKey);
    final encSecretPacked = await packageSecretKey(encryptionKeyPair.secretKey);

    if (sigVerifyPacked == null || sigSignPacked == null || encPubPacked == null || encSecretPacked == null) {
      sendLog("Error: Failed to package one or more keys for recovery data.");
      return null;
    }

    final jsonData = jsonEncode({
      "sig_ver": sigVerifyPacked,
      "sig_sig": sigSignPacked,
      "enc_pub": encPubPacked,
      "enc_sec": encSecretPacked,
    });

    final encryptedBytes = await encryptSymmetric(key: key, message: utf8.encode(jsonData));
    if (encryptedBytes == null) {
      sendLog("Error: Failed to encrypt recovery data.");
      return null;
    }

    return base64Encode(encryptedBytes);
  }
}
