import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/policy_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_page.dart';
import 'package:chat_interface/pages/status/setup/smooth_dialog.dart';
import 'package:chat_interface/pages/status/setup/tokens_setup.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/pages/status/setup/settings_setup.dart';
import 'package:chat_interface/pages/status/setup/server_setup.dart';
import 'package:chat_interface/pages/status/setup/updates_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../error/error_page.dart';

abstract class Setup {
  final String name;
  final bool once;
  bool executed = false;

  Setup(this.name, this.once);

  Future<Widget?> load();
}

SetupManager setupManager = SetupManager();

class SetupManager {
  static bool setupFinished = false;
  final _steps = <Setup>[];
  int current = -1;
  final message = 'setup.loading'.obs;
  SmoothDialogController? controller;

  SetupManager() {
    // Initialize setup

    // Setup app
    if (!isWeb) {
      _steps.add(PolicySetup());
    }
    if (GetPlatform.isWindows) {
      _steps.add(UpdateSetup());
    }
    _steps.add(InstanceSetup());
    _steps.add(ServerSetup());
    _steps.add(SettingsSetup());
    _steps.add(TokensSetup());
  }

  void retry() {
    current = -1;
    if (controller == null) {
      Get.offAll(const SetupPage());
    } else {
      controller!.transitionTo(const SetupLoadingWidget());
      next(open: false);
    }
    db.close();
  }

  void next({bool open = true}) async {
    if (_steps.isEmpty) return;
    setupFinished = false;

    if (open) {
      if (controller != null) {
        controller!.transitionTo(const SetupLoadingWidget());
      } else {
        Get.offAll(const SetupPage());
      }
    }

    current++;
    if (current < _steps.length) {
      final setup = _steps[current];
      if (setup.executed && setup.once) {
        next(open: false);
        return;
      }

      sendLog(setup.name);
      message.value = setup.name;

      Widget? ready;
      if (isDebug) {
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
        controller!.transitionTo(ready);
        return;
      }

      setup.executed = true;
      next(open: false);
    } else {
      // Finish the setup and go to the chat page
      setupFinished = true;
      sendLog("chatto");
      if (controller != null) {
        await controller!.transitionComplete;
      }
      controller = null;
      Get.offAll(getChatPage(), transition: Transition.fade, duration: const Duration(milliseconds: 500));
      Get.find<ConnectionController>().tryConnection();
    }
  }

  void error(String error) {
    controller!.transitionTo(ErrorPage(title: error));
  }
}
