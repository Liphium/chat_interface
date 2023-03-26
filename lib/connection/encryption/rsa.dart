import 'dart:convert';

import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';

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

String packagePublicKey(RSAPublicKey key) {
  return base64Encode(utf8.encode("${key.modulus}:${key.exponent}"));
}

RSAPublicKey unpackagePublicKey(String key) {
  final parts = utf8.decode(base64Decode(key)).split(":");
  return RSAPublicKey(BigInt.parse(parts[0]), BigInt.parse(parts[1]));
}

String packagePrivateKey(RSAPrivateKey key) {
  return base64Encode(utf8.encode("${key.modulus}:${key.exponent}:${key.p}:${key.q}"));
}

RSAPrivateKey unpackagePrivateKey(String key) {
  final parts = utf8.decode(base64Decode(key)).split(":");
  return RSAPrivateKey(BigInt.parse(parts[0]), BigInt.parse(parts[1]), BigInt.parse(parts[2]), BigInt.parse(parts[3]));
}

late enc.Encrypter rsaEncrypter;

void init(String publicKey, String privateKey) {
  rsaEncrypter = enc.Encrypter(
    enc.RSA(
      publicKey: unpackagePublicKey(publicKey),
      privateKey: unpackagePrivateKey(privateKey)
    )
  );
}

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> toKeyPair(String pub, String priv) {
  return AsymmetricKeyPair(unpackagePublicKey(pub), unpackagePrivateKey(priv));
}

String encryptPrivateKey(RSAPrivateKey key, String password, String username, String salt) {
  return encryptAES(packagePrivateKey(key), generateSecureKey(password, username, salt)).base64;
}

String sign(RSAPrivateKey key, String digest) {

  final signer = enc.Signer(enc.RSASigner(enc.RSASignDigest.SHA256, privateKey: key));
  return signer.sign(digest).base64;
}

bool verifySignature(String signature, RSAPublicKey key, String digest) {

  final verifier = enc.Signer(enc.RSASigner(enc.RSASignDigest.SHA256, publicKey: key));
  return verifier.verify64(digest, signature);
}

String decryptRSA64(String encrypted, RSAPrivateKey key) {
  
  final encrypter = enc.Encrypter(enc.RSA(privateKey: key));
  final iv = enc.IV.fromLength(16);
  
  return encrypter.decrypt64(encrypted, iv: iv);
}

String encryptRSA64(String message, RSAPublicKey key) {
  
  final encrypter = enc.Encrypter(enc.RSA(publicKey: key));
  final iv = enc.IV.fromLength(16);

  return encrypter.encrypt(message, iv: iv).base64;
}
