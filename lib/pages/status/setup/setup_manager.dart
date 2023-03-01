import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/profile_setup.dart';
import 'package:chat_interface/pages/status/setup/updates_setup.dart';
import 'package:chat_interface/pages/status/starting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../initialization_page.dart';
import 'account_setup.dart';

abstract class Setup {
  final Widget widget;
  final String name;
  
  Setup(this.name, this.widget);

  Future<bool> load();
}

SetupManager setupManager = SetupManager();

class SetupManager {
  
  final _steps = <Setup>[];
  int current = -1;
  final message = 'setup.loading'.obs;

  SetupManager() {

    // Initialize setups
    _steps.add(UpdateSetup());
    _steps.add(AccountSetup());
    _steps.add(ProfileSetup());
  }

  void restart() {
    current = -1;
    Get.offAll(const StartingPage(), transition: Transition.fade, duration: const Duration(milliseconds: 500));
  }

  void next() async {
    if (_steps.isEmpty) return;
    
    if (current++ != _steps.length) {
      final setup = _steps[current];
      message.value = setup.name;

      final ready = await setup.load();
      if (!ready) {
        logger.i('Setup failed, restarting...');
        Get.offAll(setup.widget, transition: Transition.fade, duration: const Duration(milliseconds: 500));
        return;
      }

      next();
    } else {
      Get.offAll(const InitializationPage());
    }
  }
}