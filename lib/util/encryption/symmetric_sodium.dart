import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_interface/main.dart';
import 'package:sodium_libs/sodium_libs.dart';

String encryptSymmetric(String data, SecureKey key, [Sodium? sd]) {
  final sodium = sd ?? sodiumLib;
  final nonce = sodium.randombytes.buf(sodium.crypto.secretBox.nonceBytes);
  final plainTextBytes = data.toCharArray().unsignedView();
  return base64Encode(
    nonce + sodium.crypto.secretBox.easy(key: key, nonce: nonce, message: plainTextBytes),
  );
}

Uint8List encryptSymmetricBytes(Uint8List data, SecureKey key, [Sodium? sd]) {
  final sodium = sd ?? sodiumLib;
  final nonce = sodium.randombytes.buf(sodium.crypto.secretBox.nonceBytes);
  final finalList = Uint8List(nonce.length + data.length + sodium.crypto.secretBox.macBytes);
  finalList.setAll(0, nonce);
  finalList.setAll(
    nonce.length,
    sodium.crypto.secretBox.easy(key: key, nonce: nonce, message: data),
  );
  return finalList;
}

String decryptSymmetric(String data, SecureKey key, [Sodium? sd]) {
  final sodium = sd ?? sodiumLib;
  final byteData = base64Decode(data);
  final nonce = byteData.sublist(0, sodium.crypto.secretBox.nonceBytes);
  final encrypted = byteData.sublist(sodium.crypto.secretBox.nonceBytes);

  return utf8.decode(
    sodium.crypto.secretBox.openEasy(key: key, nonce: nonce, cipherText: encrypted),
  );
}

Uint8List decryptSymmetricBytes(Uint8List data, SecureKey key, [Sodium? sd]) {
  final sodium = sd ?? sodiumLib;
  final nonce = data.sublist(0, sodium.crypto.secretBox.nonceBytes);
  final encrypted = data.sublist(sodium.crypto.secretBox.nonceBytes);

  return sodium.crypto.secretBox.openEasy(key: key, nonce: nonce, cipherText: encrypted);
}

SecureKey randomSymmetricKey([Sodium? sd]) {
  final Sodium sodium = sd ?? sodiumLib;
  return sodium.crypto.secretBox.keygen();
}

String packageSymmetricKey(SecureKey key) {
  return base64Encode(key.extractBytes());
}

SecureKey unpackageSymmetricKey(String key, [Sodium? sd]) {
  final Sodium sodium = sd ?? sodiumLib;
  return SecureKey.fromList(sodium, base64Decode(key));
}
