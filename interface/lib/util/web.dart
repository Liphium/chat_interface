import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/pages/status/setup/account/remote_id_setup.dart';
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

String nodeProtocol = "http://";
String basePath = 'http://localhost:3000';

Uri server(String path) {
  return Uri.parse('$basePath$path');
}

// Post request to node-backend
Future<Response> postRq(String path, Map<String, dynamic> body) async {
  return await post(
    server(path),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
}

// Post request to node-backend (new)
Future<Map<String, dynamic>> postJSON(String path, Map<String, dynamic> body, {String defaultError = "server.error"}) async {

  final res = await post(
    server(path),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if(res.statusCode != 200) {
    return <String, dynamic>{
      "success": false,
      "error": defaultError
    };
  }

  return jsonDecode(res.body);
}

// Post request to node-backend with any token
Future<Response> postRqAuth(String path, Map<String, dynamic> body, String token) async {
  return await post(
    server(path),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode(body),
  );
}

// Post request to node-backend with any token (new)
Future<Map<String, dynamic>> postAuthJSON(String path, Map<String, dynamic> body, String token, {String defaultError = "server.error"}) async {

  final res = await post(
    server(path),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode(body),
  );

  if(res.statusCode != 200) {
    return <String, dynamic>{
      "success": false,
      "error": defaultError
    };
  }

  return jsonDecode(res.body);
}

// Post request to node-backend with session token
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

// Post request to node-backend with session token (new)
Future<Map<String, dynamic>> postAuthorizedJSON(String path, Map<String, dynamic> body, {String defaultError = "server.error"}) async {
  
  final res = await post(
    server(path),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $sessionToken'
    },
    body: jsonEncode(body),
  );

  if(res.statusCode != 200) {
    return <String, dynamic>{
      "success": false,
      "error": defaultError
    };
  }

  return jsonDecode(res.body);
}

// Post request to chat-node with any token (node needs to be connected already)
Future<Response> postRqNode(String path, Map<String, dynamic> body) async {
  return await post(
    Uri.parse("$nodeProtocol$nodeDomain$path"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${randomRemoteID()}'
    },
    body: jsonEncode(body),
  );
}

// Post request to chat-node with any token (node needs to be connected already) (new)
Future<Map<String, dynamic>> postNodeJSON(String path, Map<String, dynamic> body, {String defaultError = "server.error"}) async {

  final res = await post(
    Uri.parse("$nodeProtocol$nodeDomain$path"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${randomRemoteID()}'
    },
    body: jsonEncode(body),
  );

  if(res.statusCode != 200) {
    return <String, dynamic>{
      "success": false,
      "error": defaultError
    };
  }

  return jsonDecode(res.body);
}

String padBase64(String str) {
  return str.padRight(str.length + (4 - str.length % 4) % 4, '=');
}

String getSessionFromJWT(String token) {
  final parts = token.split('.');
  final padded = padBase64(parts[1]);
  final decoded = utf8.decode(base64Decode(padded));
  
  return jsonDecode(decoded)['ses'];
}

// Creates a stored action with the given name and payload
String storedAction(String name, Map<String, dynamic> payload) {

  final prefixJson = <String, dynamic>{
    "a": name,
  };
  prefixJson.addAll(payload);

  return jsonEncode(prefixJson);
}

