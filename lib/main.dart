import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/controller/controller_manager.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_card.dart';
import 'package:chat_interface/src/rust/frb_generated.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart' as log;
import 'package:sodium_libs/sodium_libs.dart';
import 'package:chat_interface/src/rust/api/interaction.dart' as api;

import 'app.dart';

var logger = log.Logger();
final dio = Dio();
late final Sodium sodiumLib;
const appId = 1;
const appVersion = 1; // TODO: ALWAYS change to the new one saved in the node backend
const bool isDebug = true; // TODO: Set to false before release
const bool checkVersion = false; // TODO: Set to true in release builds
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sendLog(packageRSAPublicKey(generateRSAKey(2048).publicKey));

  // Initialize sodium
  await initSodium();

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
