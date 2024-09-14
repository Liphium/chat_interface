import 'package:chat_interface/theme/components/ssr/ssr_renderer.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SSR {
  /// The path the SSR rendering starts with calling
  final String startPath;

  /// This function will be called when the SSR flow is finished according to the server
  Function(Map<String, dynamic>) onSuccess;

  /// Called when the SSR flow has new widgets to present to the client
  Function(Widget) onRender;

  /// The function called for making a request to the server (called with the path and the SSR body)
  Future<Map<String, dynamic>> Function(String, Map<String, dynamic>) doRequest;

  /// Extra widget that should be appended to the rest of the server-rendered UI (by path)
  Map<String, Widget>? extra;

  // All data required for the UI
  final currentInputValues = <String, dynamic>{};
  String? currentToken;
  final error = "".obs;
  Map<String, dynamic>? suggestButton;

  SSR({required this.startPath, required this.onSuccess, required this.onRender, this.doRequest = postJSON});

  /// Start the SSR flow (returns an error message or null if successful)
  Future<String?> start({Map<String, Widget>? extra}) async {
    this.extra = extra;
    return next(startPath);
  }

  /// Call the next endpoint for SSR (can be recursive)
  Future<String?> next(String path, {int redirects = 0}) async {
    // Prevent infinite recursion caused by some server error
    if (redirects > 3) {
      sendLog("infinite recursion error with SSR, what da hell is the server trying?");
      return "server.error".tr;
    }

    if (currentToken != null) {
      // Build the request body to send to the server
      final baseTokenMap = <String, dynamic>{
        "token": currentToken,
      };
      baseTokenMap.addAll(currentInputValues);

      // Send a request to the server
      final json = await doRequest.call(path, baseTokenMap);
      if (!json["success"]) {
        return json["error"];
      }

      // Handle the response in the SSR format
      return _handleSSRResponse(path, json);
    } else {
      // If there is no token yet, call without input values
      final json = await doRequest.call(path, currentInputValues);
      if (!json["success"]) {
        return json["error"];
      }

      // Handle the response in the SSR format
      return _handleSSRResponse(path, json);
    }
  }

  /// Handles the different SSR response types
  Future<String?> _handleSSRResponse(String basePath, Map<String, dynamic> json, {int redirects = 0}) async {
    switch (json["type"]) {
      case "redirect":
        currentToken = json["token"];
        sendLog("token is now $currentToken");
        currentInputValues.clear();
        return next(json["redirect"], redirects: redirects);
      case "render":
        currentInputValues.clear();
        _renderWidgets(basePath, json["render"]);
        return null;
      case "success":
        onSuccess.call(json["data"]);
        return null;
      case "popup":
        showPopup(json["title"], json["content"]);
        return null;
      case "suggest":
        suggestButton = json["button"];
        return json["message"];
    }

    return null;
  }

  /// Returns a SSR renderer to render the components in a render response
  void _renderWidgets(String path, List<dynamic> json) {
    onRender.call(SSRRenderer(
      key: ValueKey(path),
      ssr: this,
      json: json,
      path: path,
    ));
  }
}
