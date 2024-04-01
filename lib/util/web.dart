import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/app/server_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:dio/dio.dart' as d;
import 'package:get/get.dart' as g;
import 'package:http/http.dart';
import 'package:pointycastle/export.dart';
import 'package:sodium_libs/sodium_libs.dart';

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

const authorizationHeader = "Authorization";
String nodeProtocol() {
  return isHttps ? "https://" : "http://";
}

String basePath = 'http://localhost:3000';
RSAPublicKey? serverPublicKey;

String nodePath(String path) {
  return "${nodeProtocol()}$nodeDomain$path";
}

String authorizationValue() {
  return "Bearer $sessionToken";
}

String serverPath(String path, {String? instance}) {
  path = path.startsWith("/") ? path : "/$path";
  return "${instance == null ? basePath : "$instance/$apiVersion"}$path";
}

Uri server(String path) {
  return Uri.parse('$basePath$path');
}

/// Grab the public key from the server
Future<bool> grabServerPublicKey() async {
  final Response res;
  try {
    res = await post(server("/pub"));
  } catch (e) {
    return false;
  }
  if (res.statusCode != 200) {
    return false;
  }

  final json = jsonDecode(res.body);
  serverPublicKey = unpackageRSAPublicKey(json['pub']);
  sendLog("RETRIEVED SERVER PUBLIC KEY: $serverPublicKey");

  return true;
}

/// Post request to node-backend (with Through Cloudflare Protection)
Future<Map<String, dynamic>> postJSON(String path, Map<String, dynamic> body, {String defaultError = "server.error", String? token}) async {
  if (serverPublicKey == null) {
    final success = await grabServerPublicKey();
    if (!success) {
      return <String, dynamic>{"success": false, "error": defaultError};
    }
  }

  return _postTCP(serverPublicKey!, server(path).toString(), body, defaultError: defaultError, token: token);
}

/// Post request to any server (with Through Cloudflare Protection)
Future<Map<String, dynamic>> _postTCP(RSAPublicKey key, String url, Map<String, dynamic> body, {String defaultError = "server.error", String? token}) async {
  final aesKey = randomAESKey();
  final aesBase64 = base64Encode(aesKey);
  Response? res;
  final authTag = base64Encode(encryptRSA(aesKey, key));
  try {
    res = await post(
      Uri.parse(url),
      headers: <String, String>{
        if (token != null) "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Auth-Tag": authTag,
      },
      body: encryptAES(jsonEncode(body).toCharArray().unsignedView(), aesBase64),
    );
  } catch (e) {
    return <String, dynamic>{"success": false, "error": "error.network"};
  }

  if (res.statusCode != 200) {
    return <String, dynamic>{"success": false, "code": res.statusCode, "error": defaultError};
  }

  return jsonDecode(String.fromCharCodes(decryptAES(res.bodyBytes, aesBase64)));
}

// Post request to node-backend with any token (new)
Future<Map<String, dynamic>> postAuthJSON(String path, Map<String, dynamic> body, String token) async {
  return postJSON(path, body, token: token);
}

// Post request to node-backend with session token (new)
Future<Map<String, dynamic>> postAuthorizedJSON(String path, Map<String, dynamic> body) async {
  return postJSON(path, body, token: sessionToken);
}

// Post request to chat-node with any token (node needs to be connected already) (new)
Future<Map<String, dynamic>> postNodeJSON(String path, Map<String, dynamic> body, {String defaultError = "server.error"}) async {
  if (connector.nodePublicKey == null) {
    return <String, dynamic>{"success": false, "error": defaultError};
  }

  return _postTCP(connector.nodePublicKey!, "${nodeProtocol()}$nodeDomain$path", body, defaultError: defaultError, token: sessionToken);
}

// Post request to any domain
Future<Map<String, dynamic>> postAny(String url, Map<String, dynamic> body, {String defaultError = "server.error"}) async {
  final res = await dio.post(
    url,
    data: jsonEncode(body),
    options: d.Options(
      validateStatus: (status) => status != 404,
    ),
  );
  if (res.statusCode != 200) {
    return <String, dynamic>{"success": false, "error": defaultError};
  }

  return res.data;
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

/// Translate an error with parameters (for example: file.not_uploaded:PARAMETER)
String translateError(String error) {
  final args = error.split(":");
  if (args.length == 1) {
    return error.tr;
  }
  final map = <String, String>{};
  for (int i = 1; i < args.length; i++) {
    sendLog(args[i]);
    map[i.toString()] = args[i];
  }
  return args[0].trParams(map);
}
