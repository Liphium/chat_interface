import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/controller/controller_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as log;

import 'app.dart';

var logger = log.Logger();
const appId = 0;
const bool isDebug = true;

const liveKitURL = "wss://fj-chat-xc5qv7y8.livekit.cloud";

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controllers
  initializeControllers();

  runApp(const ChatApp());
}

