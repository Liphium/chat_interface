import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/controller_manager.dart';
import 'package:chat_interface/src/rust/frb_generated.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:chat_interface/src/rust/api/interaction.dart' as api;
import 'package:window_manager/window_manager.dart';

import 'app.dart';

// Configuration constants
const appTag = "liphium_chat";
const protocolVersion = 1;

final dio = Dio();
late final Sodium sodiumLib;
bool isHttps = true;
const bool driftLogger = true;

// Build level settings
const bool isDebug = bool.fromEnvironment("DEBUG_MODE", defaultValue: true);
const bool checkVersion = bool.fromEnvironment("CHECK_VERSION", defaultValue: true);
const bool configDisableRust = bool.fromEnvironment("DISABLE_RUST", defaultValue: false);

// Authentication types
enum AuthType {
  password(0, "password"),
  totp(1, "totp"),
  recoveryCode(2, "recoveryCode"),
  passkey(3, "passkey");

  final int id;
  final String name;

  const AuthType(this.id, this.name);

  static AuthType fromId(int id) {
    return AuthType.values.firstWhere((element) => element.id == id);
  }
}

const liveKitURL = "";

Future<bool> initSodium() async {
  sodiumLib = await SodiumInit.init();
  return true;
}

final list = <String>[].obs;

var executableArguments = <String>[];

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    if (!GetPlatform.isMobile) {
      await windowManager.ensureInitialized();
    }
  }
  executableArguments = args;
  sendLog("Current save directory: ${(await getApplicationSupportDirectory()).path}");

  // Initialize sodium
  await initSodium();
  print(packageSymmetricKey(randomSymmetricKey()));

  await RustLib.init();

  // Initialize logging from the native side
  if (configDisableRust) {
    api.createLogStream().listen((event) {
      sendLog("FROM RUST: ${event.tag} | ${event.msg}");
    });
  }

  // Wait for it to be finished
  await Future.delayed(100.ms);

  if (isDebug) {
    await encryptionTest();
    // testEncryptionRSA(); This crashes the app for anyone not on my windows system xd
  }

  // Initialize controllers
  initializeControllers();

  if (!GetPlatform.isMobile) {
    await windowManager.setMinimumSize(const Size(300, 500));
    await windowManager.setTitle("Liphium");
    if (!isDebug) {
      await windowManager.setAlignment(Alignment.center);
    }
  }

  runApp(const ChatApp());
}

Future<bool> encryptionTest() async {
  final bob = generateAsymmetricKeyPair();
  final alice = generateAsymmetricKeyPair();

  const message = "Hello world!";
  final encrypted = encryptAsymmetricAuth(bob.publicKey, alice.secretKey, message);

  // This should throw an exception
  final result = decryptAsymmetricAuth(bob.publicKey, bob.secretKey, encrypted);
  if (!result.success) {
    sendLog("Authenticated encryption works!");
  }
  return true;
}
