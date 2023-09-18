
import 'dart:convert';

import 'package:crypto/crypto.dart';

String hashSha(String input) {
  
  var bytes = utf8.encode(input);
  var digest = sha256.convert(bytes);
  
  return base64Encode(digest.bytes);
}