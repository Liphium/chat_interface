import 'dart:convert';

import 'package:chat_interface/pages/status/register/register_code_page.dart';
import 'package:chat_interface/pages/status/register/register_finish_page.dart';
import 'package:chat_interface/pages/status/register/register_start_page.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterHandler {
  static String? registrationEmail;
  static String? registrationToken;

  static void goToRegistration([String? email]) {
    Widget page = RegisterStartPage(email: email);
    if (registrationToken != null) {
      // Get step from registration token
      final json = jsonDecode(String.fromCharCodes(base64Decode(registrationToken!.split(".")[1])));
      final step = json["s"];
      if (step == 1) {
        page = const RegisterCodePage();
      } else {
        page = const RegisterFinishPage();
      }
    }

    Get.find<TransitionController>().modelTransition(page);
  }

  /// Start the registration process (returns an error or null if successful)
  static Future<String?> startRegister(RxBool loading, String email, String invite) async {
    loading.value = true;
    registrationEmail = email;

    // Send a start request to the server
    final json = await postJSON("/auth/register/start", {
      "email": email,
      "invite": invite,
    });
    loading.value = false;

    // Check if the request was successful
    if (!json["success"]) {
      return json["error"];
    }

    // Set the token
    registrationToken = json["token"];
    return null;
  }

  /// Verify the code sent to email (returns an error or null if successful)
  static Future<String?> verifyCode(RxBool loading, String code) async {
    loading.value = true;

    // Send a code verify request to the server
    final json = await postJSON("/auth/register/code", {
      "token": registrationToken,
      "code": code,
    });
    loading.value = false;

    // Check if the request was successful
    if (!json["success"]) {
      return json["error"];
    }

    // Set the token
    registrationToken = json["token"];

    return null;
  }

  /// Finish the registration (returns an error or null if successful)
  static Future<String?> finishRegistration(RxBool loading, String username, String displayName, String password) async {
    loading.value = true;

    // Send a register finish request to the server
    final json = await postJSON("/auth/register/finish", {
      "token": registrationToken,
      "username": username,
      "display_name": displayName,
      "password": password,
    });
    loading.value = false;

    // Check if the request was successful
    if (!json["success"]) {
      return json["error"];
    }

    registrationToken = null;
    return null;
  }
}
