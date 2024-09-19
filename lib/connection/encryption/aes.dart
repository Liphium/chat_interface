import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

/// Encrypt data with AES.
Uint8List encryptAES(Uint8List data, String key) {
  final encrypter = Encrypter(AES(Key.fromBase64(key), mode: AESMode.gcm));
  final iv = IV.fromLength(12);

  final nonce = List<int>.from(iv.bytes);
  nonce.addAll(encrypter.encryptBytes(data, iv: iv).bytes);

  return Uint8List.fromList(nonce);
}

// Decrypt data with AES.
Uint8List decryptAES(Uint8List data, String key) {
  final encrypter = Encrypter(AES(Key.fromBase64(key), mode: AESMode.gcm));
  final iv = IV.fromBase64(base64Encode(data.sublist(0, 12)));

  return Uint8List.fromList(encrypter.decryptBytes(Encrypted(data.sublist(12)), iv: iv));
}

Uint8List randomAESKey() {
  return SecureRandom(32).bytes;
}
