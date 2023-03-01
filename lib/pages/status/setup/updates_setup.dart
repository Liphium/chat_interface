import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/material.dart';

class UpdateSetup extends Setup {
  UpdateSetup() : super('loading.update', const Placeholder());
  
  @override
  Future<bool> load() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}