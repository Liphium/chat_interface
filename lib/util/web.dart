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

String basePath = 'http://localhost:3000';

Uri server(String path) {
  return Uri.parse('$basePath$path');
}

Future<Response> postRq(String path, Map<String, dynamic> body) async {
  return await post(
    server(path),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
}

Future<Response> postRqAuthorized(String path, Map<String, dynamic> body) async {
  return await post(
    server(path),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $sessionToken'
    },
    body: jsonEncode(body),
  );
}