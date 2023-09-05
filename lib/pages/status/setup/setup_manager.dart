import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/chat_page.dart';
import 'package:chat_interface/pages/status/setup/account/friends_setup.dart';
import 'package:chat_interface/pages/status/setup/account/remote_id_setup.dart';
import 'package:chat_interface/pages/status/setup/account/stored_actions_setup.dart';
import 'package:chat_interface/pages/status/setup/account/subscribe_setup.dart';
import 'package:chat_interface/pages/status/setup/app/instance_setup.dart';
import 'package:chat_interface/pages/status/setup/app/settings_setup.dart';
import 'package:chat_interface/pages/status/setup/connection/cluster_setup.dart';
import 'package:chat_interface/pages/status/setup/connection/connection_setup.dart';
import 'package:chat_interface/pages/status/setup/account/profile_setup.dart';
import 'package:chat_interface/pages/status/setup/app/server_setup.dart';
import 'package:chat_interface/pages/status/setup/app/updates_setup.dart';
import 'package:chat_interface/pages/status/setup/fetch/fetch_finish_setup.dart';
import 'package:chat_interface/pages/status/setup/fetch/fetch_setup.dart';
import 'package:chat_interface/pages/status/starting_page.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../error/error_page.dart';
import 'account/account_setup.dart';
import 'account/vault_setup.dart';
import 'encryption/key_setup.dart';

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

    // Setup encryption
    _steps.add(KeySetup());

    // Fetch data
    _steps.add(RemoteIDSetup());
    _steps.add(SettingsSetup());
    _steps.add(FriendsSetup());

    // Setup connection
    _steps.add(ClusterSetup());
    _steps.add(ConnectionSetup());

    // Handle new stored actions
    _steps.add(StoredActionsSetup());

    // Setup conversations
    _steps.add(VaultSetup());
    _steps.add(SubscribeSetup());

    // Finish fetching
    _steps.add(FetchFinishSetup());
  }

  void restart() {
    current = -1;
    Get.find<TransitionController>().modelTransition(const StartingPage());
  }

  void next({bool open = true})  async {
    if (_steps.isEmpty) return;

    if(open) {
      Get.find<TransitionController>().modelTransition(const StartingPage());
    }

    current++;
    if (current < _steps.length) {
      final setup = _steps[current];
      if(setup.executed && setup.once) {
        next(open: false);
        return;
      }

      message.value = setup.name;
      sendLog("Setup: ${setup.name}");

      Widget? ready;
      if(isDebug) {
        ready = await setup.load();
      } else {
        try {
          ready = await setup.load();
        } catch (e) {
          error(e.toString());
          return;
        }
      }
      
      if (ready != null) {
        Get.find<TransitionController>().modelTransition(ready);
        return;
      }

      setup.executed = true;
      next(open: false);
      
    } else {
      sendLog("opening");
      Get.offAll(const ChatPage(), transition: Transition.fade, duration: const Duration(milliseconds: 500));
    }
  }


  void error(String error) {
    Get.find<TransitionController>().modelTransition(ErrorPage(title: error));
  }
}