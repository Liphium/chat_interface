
import 'package:encrypt/encrypt.dart';

Encrypted encryptAES(String data, String key) {

  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
  final iv = IV.fromLength(16);

  return encrypter.encrypt(data, iv: iv);
}

String fillKey(String key) {
  key = key.padRight(32, "!");
  return key.substring(0, 32);
}