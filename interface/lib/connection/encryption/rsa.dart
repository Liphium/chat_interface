import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';
import 'package:sodium_libs/sodium_libs.dart';

const standardKeySize = 2048;

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
///* Packaging order: modulus, exponent
String packageRSAPublicKey(RSAPublicKey key) {
  return base64Encode("${key.modulus!.toRadixString(36)}:${key.exponent!.toRadixString(36)}".toCharArray().unsignedView());
}

/// Unpackage a public key from a string.
RSAPublicKey unpackageRSAPublicKey(String key) {
  final parts = key.split(":");
  return RSAPublicKey(BigInt.parse(parts[0], radix: 36), BigInt.parse(parts[1], radix: 36));
}
/// Package a private key into a string.
///* Packaging order: modulus, public exponent, private exponent, p, q
String packagePrivateKey(RSAPrivateKey key) {
  return "${key.modulus!.toRadixString(36)}:${key.publicExponent!.toRadixString(36)}:${key.privateExponent!.toRadixString(36)}:${key.p!.toRadixString(36)}:${key.q!.toRadixString(36)}";
}

/// Unpackage a private key from a string.
RSAPrivateKey unpackagePrivateKey(String key) {
  final parts = utf8.decode(base64Decode(key)).split(":");
  return RSAPrivateKey(BigInt.parse(parts[0], radix: 36), BigInt.parse(parts[2], radix: 36), BigInt.parse(parts[3], radix: 36), BigInt.parse(parts[4], radix: 36));
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

// Encrypt bytes with a public key.
Uint8List encryptRSA(Uint8List message, RSAPublicKey key) {
  
  final encrypter = enc.Encrypter(enc.RSA(publicKey: key));
  final iv = enc.IV.fromLength(16);

  return encrypter.encryptBytes(message, iv: iv).bytes;
}

// Decrypt bytes with a private key.
List<int> decryptRSA(Uint8List encrypted, RSAPrivateKey key) {
  
  final encrypter = enc.Encrypter(enc.RSA(privateKey: key));
  final iv = enc.IV.fromLength(16);

  return encrypter.decryptBytes(enc.Encrypted(encrypted), iv: iv);
}