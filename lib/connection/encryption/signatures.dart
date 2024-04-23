import 'dart:convert';

import 'package:chat_interface/main.dart';
import 'package:drift/drift.dart';
import 'package:sodium_libs/sodium_libs.dart';

KeyPair generateSignatureKeyPair([Sodium? sd]) {
  return (sd ?? sodiumLib).crypto.sign.keyPair();
}

// Encrypts a message (secret key is the key of the sender and public key is the key of the receiver)
String signMessage(SecureKey privateKey, String message, [Sodium? sd]) {
  final Sodium sodium = sd ?? sodiumLib;
  final plainTextBytes = message.toCharArray().unsignedView();
  final signed = sodium.crypto.sign.detached(message: plainTextBytes, secretKey: privateKey);
  return base64Encode(signed);
}

/// message = message to check, signature = "encrypted" signature, publicKey = public key of the sender
bool checkSignature(String signature, Uint8List publicKey, String message, [Sodium? sd]) {
  final Sodium sodium = sd ?? sodiumLib;
  final plainTextBytes = message.toCharArray().unsignedView();
  return sodium.crypto.sign.verifyDetached(signature: base64Decode(signature), message: plainTextBytes, publicKey: publicKey);
}
