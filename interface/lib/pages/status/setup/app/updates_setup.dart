import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UpdateSetup extends Setup {
  UpdateSetup() : super('loading.update', false);
  
  @override
  Future<Widget?> load() async {
    await Future.delayed(100.ms);
    return null;
  }
}