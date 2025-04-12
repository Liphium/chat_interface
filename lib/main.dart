import 'dart:async';

import 'package:chat_interface/controller/controller_manager.dart';
import 'package:chat_interface/pages/settings/app/log_settings.dart';
import 'package:chat_interface/src/rust/api/engine.dart';
import 'package:chat_interface/src/rust/api/general.dart';
import 'package:chat_interface/src/rust/frb_generated.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

// Configuration constants
const appTag = "liphium_chat";
const appTagSpaces = "liphium_spaces";
const protocolVersion = 8;

final dio = Dio();
late final Sodium sodiumLib;
bool isHttps = true;
const bool driftLogger = true;
const bool isWeb = kIsWeb || kIsWasm;

// Build level settings
const bool isDebug = bool.fromEnvironment("DEBUG_MODE", defaultValue: true);
const bool checkVersion = bool.fromEnvironment("CHECK_VERSION", defaultValue: true);

Future<bool> initSodium() async {
  sodiumLib = await SodiumInit.init();
  return true;
}

var executableArguments = <String>[];

void main(List<String> args) async {
  // Initialize libspaceship
  await RustLib.init();
  await stopAllEngines();

  // Create a log stream for communication with libspaceship
  createLogStream().listen((log) {
    sendLog("rust: $log");
  });

  // Handle errors from flutter
  final originalFunction = FlutterError.onError!;
  FlutterError.onError = (details) {
    LogManager.addError(details.exception, details.stack);
    originalFunction(details);
  };

  if (isDebug) {
    // In Debug mode, this stuff will be printed to the console anyway
    unawaited(initApp(args));
  } else {
    // Run everything in a zone for error collection
    unawaited(
      runZonedGuarded(
        () async {
          unawaited(initApp(args));
        },
        (error, stack) {
          LogManager.addError(error, stack);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) async {
            await LogManager.addLog(line);
            parent.print(zone, line);
          },
        ),
      ),
    );
  }
}

/// App init function, start Liphium Chat
Future<void> initApp(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  executableArguments = args;
  if (!isWeb) {
    sendLog("Current save directory: ${(await getApplicationSupportDirectory()).path}");
  }

  // Initialize sodium
  await initSodium();

  // Initialize the window
  await initDesktopWindow();

  // Wait for it to be finished
  await Future.delayed(100.ms);

  // Initialize controllers
  initializeControllers();

  runApp(const ChatApp());
}

Future<void> initDesktopWindow() async {
  if (isDesktopPlatform()) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(300, 500));
    await windowManager.setTitle("Liphium");
    if (!isDebug) {
      await windowManager.setAlignment(Alignment.center);
    }
  }
}

bool isDesktopPlatform() {
  if (kIsWeb || kIsWasm) {
    return false;
  }
  return GetPlatform.isDesktop;
}
