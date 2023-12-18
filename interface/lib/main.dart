
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/controller_manager.dart';
import 'package:chat_interface/ffi.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logger/logger.dart' as log;
import 'package:sodium_libs/sodium_libs.dart';

import 'app.dart';

var logger = log.Logger();
final dio = Dio();
late final Sodium sodiumLib;
const appId = 1;
const appVersion = 1; // TODO: ALWAYS change to the new one saved in the node backend
const bool isDebug = true; // TODO: Set to false before release
const bool checkVersion = false; // TODO: Set to true in release builds
const bool driftLogger = false;

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

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  sendLog(packageRSAPublicKey(generateRSAKey(2048).publicKey));

  // Initialize sodium
  await initSodium();

  // Initialize logging from the native side
  api.createLogStream().listen((event) {
    sendLog("${event.tag} | ${event.msg}");
  });

  // Wait for it to be finished
  await Future.delayed(100.ms);

  if(isDebug) {
    await encryptionTest();
  }
  
  // Initialize controllers
  initializeControllers();

  runApp(ChatApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Clipping Example'),
        ),
        body: Center(
          child: SizedBox(
            width: 200,
            child: OverflowBox(
              minWidth: 0.0,
              maxWidth: double.infinity,
              minHeight: 0.0,
              maxHeight: double.infinity,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    color: Colors.blue,
                    height: 100.0,
                    child: Center(
                      child: Text(
                        'This is some text that overflows ausdhasdiha sdah usdhuasudha shuduhas uhdauhsduhasuhdasui asdasduisahduash dahud uhasuhduh asuhd auhsd uhuah sduh auhsduhasuhdhuasduashudasuhduhasdusahudsaudhd',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> encryptionTest() async {

  final bob = generateAsymmetricKeyPair();
  final alice = generateAsymmetricKeyPair();

  const message = "Hello world!";
  final encrypted = encryptAsymmetricAuth(bob.publicKey, alice.secretKey, message);

  // This should throw an exception
  final result = decryptAsymmetricAuth(bob.publicKey, bob.secretKey, encrypted);
  if(!result.success) {
    sendLog("Authenticated encryption works!");
  }
  return true;
}

