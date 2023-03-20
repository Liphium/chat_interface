
import 'package:encrypt/encrypt.dart';

Encrypted encryptAES(String data, String key) {

  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
  final iv = IV.fromLength(16);

  return encrypter.encrypt(data, iv: iv);
}

String fill(String input, int length) {
  input = input.padRight(length, "!");
  return input.substring(0, length);
}

String generateSecureKey(String password, String username, String salt) {
  String key = fill(password, 16) + fill(username, 8) + fill(salt, 8);
  return key;
}