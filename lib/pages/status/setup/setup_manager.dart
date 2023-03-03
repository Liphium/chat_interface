import 'package:chat_interface/pages/chat/chat_page.dart';
import 'package:chat_interface/pages/status/setup/cluster_setup.dart';
import 'package:chat_interface/pages/status/setup/connection_setup.dart';
import 'package:chat_interface/pages/status/setup/friends_setup.dart';
import 'package:chat_interface/pages/status/setup/profile_setup.dart';
import 'package:chat_interface/pages/status/setup/server_setup.dart';
import 'package:chat_interface/pages/status/setup/updates_setup.dart';
import 'package:chat_interface/pages/status/starting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../error/error_page.dart';
import 'account_setup.dart';

abstract class Setup {
  final String name;
  
  Setup(this.name);

  Future<Widget?> load();
}

SetupManager setupManager = SetupManager();

class SetupManager {
  
  final _steps = <Setup>[];
  int current = -1;
  final message = 'setup.loading'.obs;

  SetupManager() {

    // Initialize setups
    _steps.add(UpdateSetup());
    _steps.add(ServerSetup());
    _steps.add(ProfileSetup());
    _steps.add(ClusterSetup());
    _steps.add(AccountSetup());
    _steps.add(FriendsSetup());
    _steps.add(ConnectionSetup());
  }

  void restart() {
    current = -1;
    Get.offAll(const StartingPage(), transition: Transition.fade, duration: const Duration(milliseconds: 500));
  }

  void next({bool open = true})  async {
    if (_steps.isEmpty) return;

    if(open) {
      Get.offAll(const StartingPage(), transition: Transition.fade, duration: const Duration(milliseconds: 500));
    }

    current++;
    if (current < _steps.length) {
      final setup = _steps[current];
      message.value = setup.name;
      print(setup.name);

      final ready = await setup.load();
      print(ready);
      if (ready != null) {
        Get.offAll(ready, transition: Transition.fade, duration: const Duration(milliseconds: 500));
        return;
      }

      next(open: false);
    } else {
      Get.offAll(const ChatPage(), transition: Transition.fade, duration: const Duration(milliseconds: 500));
    }
  }


  void error(String error) {
    Get.offAll(ErrorPage(title: error), transition: Transition.fade, duration: const Duration(milliseconds: 500));
  }
}