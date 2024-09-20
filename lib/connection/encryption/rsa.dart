import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/util/logging_framework.dart';
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
  final secureRandom = SecureRandom('Fortuna')..seed(KeyParameter(enc.SecureRandom(32).bytes));
  return secureRandom;
}

/// Package a public key into a string.
///* Packaging order: modulus, exponent
String packageRSAPublicKey(RSAPublicKey key) {
  return "${key.modulus!.toRadixString(36)}:${key.exponent!.toRadixString(36)}";
}

/// Unpackage a public key from a string.
RSAPublicKey unpackageRSAPublicKey(String key) {
  final parts = key.split(":");
  return RSAPublicKey(BigInt.parse(parts[0], radix: 36), BigInt.parse(parts[1], radix: 36));
}

/// Package a private key into a string.
///* Packaging order: modulus, public exponent, private exponent, p, q
String packageRSAPrivateKey(RSAPrivateKey key) {
  return "${key.modulus!.toRadixString(36)}:${key.publicExponent!.toRadixString(36)}:${key.privateExponent!.toRadixString(36)}:${key.p!.toRadixString(36)}:${key.q!.toRadixString(36)}";
}

/// Unpackage a private key from a string.
RSAPrivateKey unpackageRSAPrivateKey(String key) {
  final parts = key.split(":");
  return RSAPrivateKey(
      BigInt.parse(parts[0], radix: 36), BigInt.parse(parts[2], radix: 36), BigInt.parse(parts[3], radix: 36), BigInt.parse(parts[4], radix: 36));
}

/// Turn a public and private key into an [AsymmetricKeyPair].
AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> toRSAKeyPair(String pub, String priv) {
  return AsymmetricKeyPair(unpackageRSAPublicKey(pub), unpackageRSAPrivateKey(priv));
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

void testEncryptionRSA() {
  const String srvPriv =
      "1csunyawmdfm4wnhpv8h5f3gbgwxeq7n68r3gtoak33e0bje5zszv3nilf4qvwee4lldvnsta8isqclpjscmbicqekc6gc1c7l36bom99hlr7y77o52uh7nigyjwqo9rp6z3pi4hv4ld7ul1cp9bltwidhvttwqff9ux7312cunse1o0q4807uhbmfg44s9lhnake8d3a00dxfzi3zlke0e9z87my6sk3d074wvhhqcaq0sx61yticepum5jr08sw4ql2wv8nqlkwez2im4zq6efgf1gofp1a69yrqwkgqrtbdrllmnb6rx37ata0kw9203qi93ok2j4tq4bj247x1w5px4myhl2jkpuy0obphxf5svem81of6zzksefd39b0vys6usvfjpn1:1ekh:55m0x5tb8098nbc57dflswdjpe4m9gimbebl43c04976udcm3xd3j7kf6ql68dk7kiix1kvv4c2eqhije21fgyk1610y6cxtaaemutpt4jzqqgd5yejtyivsmtbz3m568f3q4b46mjlkfnbk0g0qnuwcfs91onssoj2w7mdfriru8y2izuhgddoxfxzrpn1xqdcf6rexme8frndvjsncepfb6kddsfcfjbgejd5ntz5i4fgz63fvj033um25xih6igyx500n7nbd9sfd4t891n0ttv5rznmbiz9cat3d48onf7o71h2kxuy6f6sutel2sodl0oxu1cbyj8j40tfn5pzzcvgziy1sk0yzqjmnnsdd4eatgstvo0wc5ogbs5iljhdto75b3ln5:15dgugvnbbwb92pp6jgvl68p2iiitgvesssq9zg4vhsx8pjm79xr3n5i5kv9b8ydtxr77argwk2n462zrw86mhrkgmpsugzw1i8jh0erqoojw7xi8447cmcb9fwqtib8xynhl11xkj27n1cmmdhdp7y3rqa6d96oxxutixkbfvx6h21nggmy10hqzzysbotdrsdezbz:16gnijn1log6fqc2wxxce86mjbsrg1czi1c3x4vp16kzl7loahy7mqg3lkoy2asn2i102hhd0b8bev7o93zjgtl1tdivpvkrbsl8249fxwre0d9896wtxk66sqzw3k6t207goz75v9ipfwr6qslqdgbq4bfq5do80dubpodzm8yhzmwfmtdbzrcoify9o0o7nu6on0z";

  final priv = unpackageRSAPrivateKey(srvPriv);
  final file = File("C:/Users/thisi/OneDrive/Desktop/testin/test.msg");
  final data = file.readAsBytesSync();

  final decrypted = decryptRSA(data, priv);
  final decryptedString = utf8.decode(decrypted);
  sendLog(decryptedString);

  final key = randomAESKey();
  sendLog(key);

  const msg = "hello world";
  final encrypted = encryptAES(msg.toCharArray().unsignedView(), base64Encode(key));
  sendLog(base64Encode(encrypted));
  final decrypted2 = decryptAES(encrypted, base64Encode(key));

  sendLog(decrypted2);
}
