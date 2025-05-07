import 'dart:convert';

import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/util/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/web.dart';
import 'package:sodium_libs/sodium_libs.dart';

class RecoveryTokenService {
  /// Generate a new recovery token.
  ///
  /// Returns the token (first) and an error (second) if there was one.
  static Future<(String?, String?)> generateNewToken() async {
    // Create the data sent to the server
    final key = randomSymmetricKey();
    final data = RecoveryKeyStorage(signatureKeyPair, asymmetricKeyPair).encrypted(key);

    // Generate a new token on the server
    final json = await postAuthorizedJSON("/account/keys/recovery/generate", {"data": data});
    if (!json["success"]) {
      return (null, json["error"] as String);
    }

    // Return the token based on the standard
    return ("${json["token"]}-${packageSymmetricKey(key)}", null);
  }
}

class RecoveryKeyStorage {
  final KeyPair signatureKeyPair;
  final KeyPair encryptionKeyPair;

  RecoveryKeyStorage(this.signatureKeyPair, this.encryptionKeyPair);

  /// Get [RecoveryKeyStorage] from the encrypted version sent to the server.
  factory RecoveryKeyStorage.fromEncrypted(String encryptedData, SecureKey key) {
    // Decrypt the json and parse
    final decryptedJson = decryptSymmetric(encryptedData, key);
    final data = jsonDecode(decryptedJson);

    // Unpackage all the keys to create the key storage
    final sigPub = unpackagePublicKey(data['sig_pub']);
    final sigPriv = unpackagePrivateKey(data['sig_priv']);
    final encPub = unpackagePublicKey(data['enc_pub']);
    final encPriv = unpackagePrivateKey(data['enc_priv']);
    return RecoveryKeyStorage(
      KeyPair(publicKey: sigPub, secretKey: sigPriv),
      KeyPair(publicKey: encPub, secretKey: encPriv),
    );
  }

  /// Encrypt [RecoveryKeyStorage] in the form stored on the server.
  String encrypted(SecureKey key) => encryptSymmetric(
    jsonEncode({
      "sig_pub": packagePublicKey(signatureKeyPair.publicKey),
      "sig_priv": packagePrivateKey(signatureKeyPair.secretKey),
      "enc_pub": packagePublicKey(encryptionKeyPair.publicKey),
      "enc_priv": packagePrivateKey(encryptionKeyPair.secretKey),
    }),
    key,
  );
}
