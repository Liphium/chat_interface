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

String encryptPrivateKey(RSAPrivateKey key, String password) {
  return encryptAES(packagePrivateKey(key), fillKey(password)).base64;
}

