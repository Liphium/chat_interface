import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/controller_manager.dart';
import 'package:chat_interface/src/rust/frb_generated.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:chat_interface/src/rust/api/interaction.dart' as api;
import 'package:window_manager/window_manager.dart';

import 'app.dart';

final dio = Dio();
late final Sodium sodiumLib;
const appId = 1;
bool isHttps = true;
const bool isDebug = true; // TODO: Set to false before release
const bool checkVersion = true; // TODO: Set to true in release builds
const bool driftLogger = true;

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
  await windowManager.ensureInitialized();
  executableArguments = args;
  sendLog("Current save directory: ${(await getApplicationSupportDirectory()).path}");

  // Initialize sodium
  await initSodium();
  print(packageSymmetricKey(randomSymmetricKey()));

  await RustLib.init();

  // Initialize logging from the native side
  api.createLogStream().listen((event) {
    sendLog("FROM RUST: ${event.tag} | ${event.msg}");
  });

  // Wait for it to be finished
  await Future.delayed(100.ms);

  if (isDebug) {
    await encryptionTest();
    // testEncryptionRSA(); This crashes the app for anyone not on my windows system xd
  }

  // Initialize controllers
  initializeControllers();

  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      minimumSize: Size(300, 500),
      fullScreen: false,
    ),
    () async {
      await windowManager.show();
    },
  );

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
