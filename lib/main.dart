import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/controller/controller_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart' as log;

import 'app.dart';

var logger = log.Logger();
const appId = 0;
const bool isDebug = true;

const liveKitURL = "wss://fj-chat-xc5qv7y8.livekit.cloud";

void main() async {

  final process = await Process.start("C:/Users/thisi/Downloads/fmedia-1.30-windows-x64/fmedia/fmedia.exe",
  ["--notui", "--record", "--debug"]);

  process.stdout.listen((list) {
    String message = utf8.decode(list);
    final args = message.split(" ");

    String? peak = args.firstWhereOrNull((element) => element.contains("maxpeak"));
    if (peak != null) {
      print(peak.split(":")[2].split("\n")[0]);
    }
  });

  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controllers
  initializeControllers();

  runApp(const ChatApp());
}

