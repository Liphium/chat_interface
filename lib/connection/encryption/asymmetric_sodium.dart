import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_interface/main.dart';
import 'package:sodium_libs/sodium_libs.dart';

/// Generates a new asymmetric key pair (secret key = private key)
KeyPair generateAsymmetricKeyPair() {
  return sodium.crypto.box.keyPair();
}

/// Encrypts a message using the given public key and the given secret key
String encryptAsymmetricNormal(Uint8List publicKey, SecureKey secureKey, String message) {

  final plainTextBytes = message.toCharArray().unsignedView();
  final nonce = sodium.randombytes.buf(sodium.crypto.secretBox.nonceBytes);

  final encrypted = sodium.crypto.box.easy(message: plainTextBytes, nonce: nonce, publicKey: publicKey, secretKey: secureKey);
  return base64Encode(nonce + encrypted);
}

/// Decrypts a message using the given public key and the given secret key
String decryptAsymmetricNormal(Uint8List publicKey, SecureKey secretKey, String message) {

  final cipherText = base64Decode(message);
  final nonce = cipherText.sublist(0, sodium.crypto.secretBox.nonceBytes);
  final encrypted = cipherText.sublist(sodium.crypto.secretBox.nonceBytes);

  final decrypted = sodium.crypto.box.openEasy(
    cipherText: encrypted,
    nonce: nonce,
    publicKey: publicKey,
    secretKey: secretKey,
  );
  return decrypted.toString();
}

String packagePublicKey(Uint8List publicKey) {
  return base64Encode(publicKey);
}

Uint8List unpackagePublicKey(String publicKey) {
  return base64Decode(publicKey);
}

String packagePrivateKey(SecureKey privateKey) {
  return base64Encode(privateKey.extractBytes());
}

SecureKey unpackagePrivateKey(String privateKey) {
  return SecureKey.fromList(sodium, base64Decode(privateKey));
}

/// For friend requests and other stored actions (that shouldn't be identifiable).
String encryptAsymmetricAnonymous(Uint8List publicKey, String message) {
  final plainTextBytes = message.toCharArray().unsignedView();
  return base64Encode(sodium.crypto.box.seal(message: plainTextBytes, publicKey: publicKey));
}

/// For friend requests and other stored actions (that shouldn't be identifiable).
/// Secret key is your secret key and public key would also be your public key.
String decryptAsymmetricAnonymous(Uint8List publicKey, SecureKey secretKey, String message) {
  final cipherText = base64Decode(message);
  final decrypted = sodium.crypto.box.sealOpen(
    cipherText: cipherText,
    publicKey: publicKey,
    secretKey: secretKey,
  );
  return decrypted.toString();
}

/// Sign a message using the given secret key
String asymmetricSignature(SecureKey secretKey, String message) {
  final plainTextBytes = message.toCharArray().unsignedView();
  return base64Encode(sodium.crypto.sign.detached(message: plainTextBytes, secretKey: secretKey));
}

/// Verify a signature using the given public key
/// Signature is the signature to verify, message is the message that was signed
bool verifySignature(Uint8List publicKey, String signature, String message) {
  final plainTextBytes = message.toCharArray().unsignedView();
  final signatureBytes = base64Decode(signature);
  return sodium.crypto.sign.verifyDetached(signature: signatureBytes, message: plainTextBytes, publicKey: publicKey);
}

KeyPair toKeyPair(String publicKey, String privateKey) {
  return KeyPair(
    publicKey: unpackagePublicKey(publicKey),
    secretKey: unpackagePrivateKey(privateKey),
  );
}