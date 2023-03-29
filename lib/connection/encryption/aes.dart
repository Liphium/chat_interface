
import 'package:encrypt/encrypt.dart';

Encrypted encryptAES(String data, String key) {

  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
  final iv = IV.fromLength(16);

  return encrypter.encrypt(data, iv: iv);
}

String decryptAES(Encrypted data, String key) {

  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
  final iv = IV.fromLength(16);

  return encrypter.decrypt(data, iv: iv);
}

String fill(String input, int length) {
  input = input.padRight(length, "!");
  return input.substring(0, length);
}

String randomAESKey() {
  return SecureRandom(32).base64.substring(0, 32);
}