import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';

/// Generate a new RSA key pair.
AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKey(int keySize) {
  final keyGen = KeyGenerator("RSA");

  keyGen.init(ParametersWithRandom(RSAKeyGeneratorParameters(BigInt.parse("65537"), keySize, 64), _secureRandom()));

  final keyPair = keyGen.generateKeyPair();
  
  final publicKey = keyPair.publicKey as RSAPublicKey;
  final privateKey = keyPair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair(publicKey, privateKey);
}

SecureRandom _secureRandom() {
  final secureRandom = SecureRandom('Fortuna')
    ..seed(KeyParameter(enc.SecureRandom(32).bytes));
  return secureRandom;
}

/// Package a public key into a string.
String packageRSAPublicKey(RSAPublicKey key) {
  return base64Encode(utf8.encode("${key.modulus}:${key.exponent}"));
}

/// Unpackage a public key from a string.
RSAPublicKey unpackageRSAPublicKey(String key) {
  final parts = utf8.decode(base64Decode(key)).split(":");
  return RSAPublicKey(BigInt.parse(parts[0]), BigInt.parse(parts[1]));
}

/// Package a private key into a string.
String packagePrivateKey(RSAPrivateKey key) {
  return base64Encode(utf8.encode("${key.modulus}:${key.exponent}:${key.p}:${key.q}"));
}

/// Unpackage a private key from a string.
RSAPrivateKey unpackagePrivateKey(String key) {
  final parts = utf8.decode(base64Decode(key)).split(":");
  return RSAPrivateKey(BigInt.parse(parts[0]), BigInt.parse(parts[1]), BigInt.parse(parts[2]), BigInt.parse(parts[3]));
}

/// Turn a public and private key into an [AsymmetricKeyPair].
AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> toRSAKeyPair(String pub, String priv) {
  return AsymmetricKeyPair(unpackageRSAPublicKey(pub), unpackagePrivateKey(priv));
}

/// Sign a message with a private key.
String signRSA(RSAPrivateKey key, String digest) {

  final signer = enc.Signer(enc.RSASigner(enc.RSASignDigest.SHA256, privateKey: key));
  return signer.sign(digest).base64;
}

/// Verify a signature with a public key.
bool verifyRSASignature(String signature, RSAPublicKey key, String digest) {

  final verifier = enc.Signer(enc.RSASigner(enc.RSASignDigest.SHA256, publicKey: key));
  return verifier.verify64(digest, signature);
}

/// Encrypt a message with a public key.
String decryptRSA64(String encrypted, RSAPrivateKey key) {
  
  final encrypter = enc.Encrypter(enc.RSA(privateKey: key));
  final iv = enc.IV.fromLength(16);
  
  return encrypter.decrypt64(encrypted, iv: iv);
}

/// Decrypt a message with a private key.
String encryptRSA64(String message, RSAPublicKey key) {
  
  final encrypter = enc.Encrypter(enc.RSA(publicKey: key));
  final iv = enc.IV.fromLength(16);

  return encrypter.encrypt(message, iv: iv).base64;
}