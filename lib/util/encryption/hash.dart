import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

String hashSha(String input) {
  var bytes = utf8.encode(input);
  var digest = sha256.convert(bytes);

  return base64Encode(digest.bytes);
}

String hashShaBytes(Uint8List input) {
  var digest = sha256.convert(input);
  return base64Encode(digest.bytes);
}
