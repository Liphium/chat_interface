import 'dart:convert';

import 'package:chat_interface/main.dart';
import 'package:encrypt/encrypt.dart';
import 'package:sodium_libs/sodium_libs.dart';

Encrypted encryptSymmetric(String data, String key) {

  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
  final iv = IV.fromLength(16);

  return encrypter.encrypt(data, iv: iv);
}

String decryptSymmetric(Encrypted data, String key) {

  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
  final iv = IV.fromLength(16);

  return encrypter.decrypt(data, iv: iv);
}


SecureKey randomSymmetricKey() {
  return sodium.crypto.secretBox.keygen();
}

String packageSymmetricKey(SecureKey key) {
  return base64Encode(key.extractBytes());
}

SecureKey unpackageSymmetricKey(String key) {
  return SecureKey.fromList(sodium, base64Decode(key));
}
