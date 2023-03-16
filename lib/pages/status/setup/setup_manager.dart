import 'package:chat_interface/pages/chat/chat_page.dart';
import 'package:chat_interface/pages/status/setup/account/conversation_setup.dart';
import 'package:chat_interface/pages/status/setup/account/requests_setup.dart';
import 'package:chat_interface/pages/status/setup/app/instance_setup.dart';
import 'package:chat_interface/pages/status/setup/connection/cluster_setup.dart';
import 'package:chat_interface/pages/status/setup/connection/connection_setup.dart';
import 'package:chat_interface/pages/status/setup/account/friends_setup.dart';
import 'package:chat_interface/pages/status/setup/account/profile_setup.dart';
import 'package:chat_interface/pages/status/setup/app/server_setup.dart';
import 'package:chat_interface/pages/status/setup/app/updates_setup.dart';
import 'package:chat_interface/pages/status/setup/fetch/fetch_finish_setup.dart';
import 'package:chat_interface/pages/status/setup/fetch/fetch_setup.dart';
import 'package:chat_interface/pages/status/starting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../error/error_page.dart';
import 'account/account_setup.dart';

abstract class Setup {
  final String name;
  final bool once;
  bool executed = false;
  
  Setup(this.name, this.once);

  Future<Widget?> load();
}

SetupManager setupManager = SetupManager();

class SetupManager {
  
  final _steps = <Setup>[];
  int current = -1;
  final message = 'setup.loading'.obs;

  SetupManager() {

    // Initialize setups

    // Setup app
    _steps.add(UpdateSetup());
    _steps.add(InstanceSetup());
    _steps.add(ServerSetup());
    
    // Start fetching
    _steps.add(FetchSetup());

    // Setup account
    _steps.add(ProfileSetup());
    _steps.add(AccountSetup());
    _steps.add(FriendsSetup());
    _steps.add(RequestSetup());
    _steps.add(ConversationSetup());

    // Finish fetching
    _steps.add(FetchFinishSetup());

    // Setup connection
    _steps.add(ClusterSetup());
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
      if(setup.executed && setup.once) {
        next(open: false);
        return;
      }

      message.value = setup.name;

      Widget? ready;
      try {
        ready = await setup.load();
      } catch (e) {
        error(e.toString());
        return;
      }

      if (ready != null) {
        Get.offAll(ready, transition: Transition.fade, duration: const Duration(milliseconds: 500));
        return;
      }

      setup.executed = true;
      next(open: false);
      
    } else {
      Get.offAll(const ChatPage(), transition: Transition.fade, duration: const Duration(milliseconds: 500));
    }
  }


  void error(String error) {
    Get.offAll(ErrorPage(title: error), transition: Transition.fade, duration: const Duration(milliseconds: 500));
  }
}