import 'dart:convert';

import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/util/encryption/aes.dart';
import 'package:chat_interface/util/encryption/rsa.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/server_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:dio/dio.dart' as d;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
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
  Map<String, String> payload = {'token': sessionToken, 'refresh_token': refreshToken};

  return jsonEncode(payload);
}

const authorizationHeader = "Authorization";
String nodeProtocol() {
  return isHttps ? "https://" : "http://";
}

String basePath = 'http://localhost:3000';
RSAPublicKey? serverPublicKey;

Map<String, RSAPublicKey> serverPublicKeys = <String, RSAPublicKey>{};

String nodePath(String path) {
  return "${nodeProtocol()}$nodeDomain$path";
}

String authorizationValue() {
  return "Bearer $sessionToken";
}

String localeString(Locale locale) {
  return "${locale.languageCode}_${locale.countryCode ?? "US"}";
}

/// Get the path to your own server
String ownServer(String path) {
  return '$basePath/$apiVersion$path';
}

/// Checks if two servers are the same
bool isSameServer(String path1, String path2) {
  return TrustedLinkHelper.extractDomain(path1) == TrustedLinkHelper.extractDomain(path2);
}

/// Class to deal with addresses for users
class LPHAddress {
  final String server;
  final String id;

  LPHAddress(this.server, this.id);

  /// Returns an address with both server and id being "-" when an error happens
  factory LPHAddress.from(String address) {
    final args = address.split("@");
    if (args.length != 2) {
      sendLog("ERROR UNPACKING ADDRESS: $address");
      return LPHAddress("-", "-");
    }
    return LPHAddress(args[1], args[0]);
  }

  /// Special constructor just for errors
  LPHAddress.error([String replacer = "-"]) : this(replacer, replacer);

  bool isError() => id == "-" || server == "-";
  String encode() => "$id@$server";

  /// So it works properly with JSON
  @override
  String toString() {
    return encode();
  }

  // Needed for hashCode to work
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LPHAddress &&
          runtimeType == other.runtimeType &&
          TrustedLinkHelper.extractDomain(server) == TrustedLinkHelper.extractDomain(other.server) &&
          id == other.id;

  // So it works properly with HashMaps
  @override
  int get hashCode => server.hashCode ^ id.hashCode;
}

/// Get the path from any server
String serverPath(String server, String path, {bool noApiVersion = false}) {
  path = path.startsWith("/") ? path : "/$path";
  if (!server.startsWith("http://") && !server.startsWith("https://")) {
    server = "https://$server";
  }
  return noApiVersion ? "$server$path" : "$server/$apiVersion$path";
}

/// Grab the public key from the server
Future<String?> grabServerPublicURL(
  String server, {
  String defaultError = "server.error",
  bool checkProtocol = true,
}) async {
  final Response res;
  try {
    res = await post(Uri.parse(serverPath(server, "/pub", noApiVersion: true)));
  } catch (e) {
    return "error.network".tr;
  }
  if (res.statusCode != 200) {
    return defaultError;
  }

  final json = jsonDecode(res.body);

  // Check the protocol versioncheckProtocol
  if (checkProtocol && json["protocol_version"] > protocolVersion) {
    return "protocol.error.client".tr;
  }

  if (checkProtocol && json["protocol_version"] < protocolVersion) {
    return "protocol.error.server".tr;
  }

  serverPublicKeys[server] = unpackageRSAPublicKey(json['pub']);
  sendLog("RETRIEVED SERVER PUBLIC KEY FROM $server");

  return null;
}

/// Post request to node-backend (with Through Cloudflare Protection)
Future<Map<String, dynamic>> postJSON(
  String path,
  Map<String, dynamic> body, {
  String defaultError = "server.error",
  String? token,
  bool checkProtocol = true,
}) {
  return postAddress(basePath, path, body, defaultError: defaultError, token: token, checkProtocol: checkProtocol);
}

/// Post request to any server (with Through Cloudflare Protection)
Future<Map<String, dynamic>> _postTCP(
  RSAPublicKey key,
  String url,
  Map<String, dynamic> body, {
  String defaultError = "server.error",
  String? token,
}) async {
  final aesKey = randomAESKey();
  final aesBase64 = base64Encode(aesKey);
  Response? res;
  final authTag = base64Encode(encryptRSA(aesKey, key));

  try {
    if (isDebug) {
      sendLog("request to $url");
    }
    res = await post(
      Uri.parse(url),
      headers: <String, String>{
        if (token != null) "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Locale": localeString(g.Get.locale ?? g.Get.fallbackLocale ?? const Locale("en", "US")),
        "Auth-Tag": authTag,
      },
      body: encryptAES(jsonEncode(body).toCharArray().unsignedView(), aesBase64),
    );
  } catch (e) {
    if (isDebug && e is Error) {
      sendLog("error: $e");
    }
    return <String, dynamic>{"success": false, "error": "error.network".tr};
  }

  if (res.statusCode != 200) {
    return <String, dynamic>{"success": false, "code": res.statusCode, "error": defaultError.tr};
  }

  return jsonDecode(utf8.decode(decryptAES(res.bodyBytes, aesBase64)));
}

/// Post request to any server (with Through Cloudflare Protection)
Future<Map<String, dynamic>> postAddress(
  String server,
  String path,
  Map<String, dynamic> body, {
  String defaultError = "server.error",
  String? token,
  bool noApiVersion = false,
  bool checkProtocol = true,
}) async {
  // Try to get the server public key
  if (serverPublicKeys[server] == null) {
    final result = await grabServerPublicURL(server, checkProtocol: checkProtocol);
    if (result != null) {
      return {"success": false, "error": result};
    }
  }

  // Do the request
  return _postTCP(
    serverPublicKeys[server]!,
    serverPath(server, path, noApiVersion: noApiVersion).toString(),
    body,
    defaultError: defaultError,
    token: token,
  );
}

// Post request to node-backend with any token (new)
Future<Map<String, dynamic>> postAuthJSON(String path, Map<String, dynamic> body, String token) async {
  return postJSON(path, body, token: token);
}

// Post request to node-backend with session token (new)
Future<Map<String, dynamic>> postAuthorizedJSON(
  String path,
  Map<String, dynamic> body, {
  bool checkProtocol = true,
}) async {
  return postJSON(path, body, token: sessionToken, checkProtocol: checkProtocol);
}

// Post request to chat-node with any token (node needs to be connected already) (new)
Future<Map<String, dynamic>> postNodeJSON(
  String path,
  Map<String, dynamic> body, {
  String defaultError = "server.error",
}) async {
  if (connector.nodePublicKey == null) {
    return <String, dynamic>{"success": false, "error": defaultError.tr};
  }

  // Check if the path is a conversations endpoint
  if (path.contains("conversations/")) {
    // Add an empty data property to the body if it's not already there
    body["data"] ??= "";
  }

  return _postTCP(
    connector.nodePublicKey!,
    "${nodeProtocol()}$nodeDomain$path",
    body,
    defaultError: defaultError,
    token: sessionToken,
  );
}

// Post request to any domain
Future<Map<String, dynamic>> postAny(
  String url,
  Map<String, dynamic> body, {
  String defaultError = "server.error",
}) async {
  try {
    final res = await dio.post(url, data: jsonEncode(body), options: d.Options(validateStatus: (status) => true));
    if (res.statusCode != 200) {
      return <String, dynamic>{"success": false, "error": defaultError.tr};
    }

    return res.data;
  } catch (e) {
    e.printError();
    return <String, dynamic>{"success": false, "error": defaultError.tr};
  }
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
  final prefixJson = <String, dynamic>{"a": name};
  prefixJson.addAll(payload);

  return jsonEncode(prefixJson);
}

// Creates an authenticated stored action with the given name and payload
Map<String, dynamic> authenticatedStoredAction(String name, Map<String, dynamic> payload) {
  final prefixJson = <String, dynamic>{"a": name};
  prefixJson.addAll(payload);

  return prefixJson;
}

/// A helper method to check if a XFile exists
Future<bool> doesFileExist(XFile file) async {
  try {
    await file.length();
    return true;
  } catch (e) {
    return false;
  }
}
