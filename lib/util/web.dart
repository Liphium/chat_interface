import 'dart:convert';

import 'package:http/http.dart';

String sessionToken = '';
String refreshToken = '';

void loadTokensFromPayload(Map<String, dynamic> payload) {
  sessionToken = payload['token'];
  refreshToken = payload['refresh_token'];
}

String tokensToPayload() {
  Map<String, String> payload = {
    'token': sessionToken,
    'refresh_token': refreshToken,
  };

  return jsonEncode(payload);
}

Uri server(String path) {
  return Uri.parse('http://localhost:3000$path');
}

Future<Response> postRq(String path, Map<String, String> body) async {
  return await post(
    server(path),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
}