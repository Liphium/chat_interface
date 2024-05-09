import 'dart:convert';

/// Class for handling unicode strings that we put into json
class UTFString {
  final String text;

  UTFString(this.text);

  factory UTFString.untransform(String transformed) {
    return UTFString(utf8.decode(base64Decode(transformed)));
  }

  String transform() => base64Encode(utf8.encode(text));
}
