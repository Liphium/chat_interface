import 'dart:async';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/conversation/townsquare_controller.dart';
import 'package:chat_interface/controller/current/steps/account_setup.dart';
import 'package:chat_interface/controller/current/steps/connection_setup.dart';
import 'package:chat_interface/controller/current/steps/friends_setup.dart';
import 'package:chat_interface/controller/current/steps/key_setup.dart';
import 'package:chat_interface/controller/current/steps/profile_setup.dart';
import 'package:chat_interface/controller/current/steps/stored_actions_setup.dart';
import 'package:chat_interface/controller/current/steps/vault_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ConnectionController extends GetxController {
  final loading = false.obs;
  final connected = false.obs;
  final error = RxString("");
  Timer? _retryTimer;
  final _steps = <ConnectionStep>[];

  ConnectionController() {
    // Setup account
    _steps.add(ProfileSetup());
    _steps.add(AccountSetup());

    // Setup encryption
    _steps.add(KeySetup());

    // Fetch data
    _steps.add(FriendsSetup());

    // Setup connection
    _steps.add(ConnectionSetup());

    // Setup conversations
    _steps.add(VaultSetup());

    // Handle new stored actions
    _steps.add(StoredActionsSetup());
  }

  void tryConnection() async {
    // Reset all previous state
    connected.value = false;
    loading.value = true;
    serverPublicKey = null;
    connector.disconnect();

    // Do all setup steps
    for (var step in _steps) {
      sendLog("connection step ${step.name}..");
      final result = await step.load();

      // If there is an error, show it
      if (result.error != null) {
        error.value = "";
        error.value = result.error?.tr ?? "";
        _retry();
        return;
      }

      // If a restart is requested, restart the setup
      if (result.restart) {
        setupManager.retry();
        return;
      }

      // If a retry is requested, retry all setups
      if (result.retryConnection) {
        await Future.delayed(500.ms); // To prevent CPU overuse in case of a bug (hopefully never happens)
        tryConnection();
        return;
      }
    }

    // Run somewhere at the end
    connector.runAfterSetupQueue();
    Get.find<TownsquareController>().updateEnabledState();
    connected.value = true;
    error.value = "";
    loading.value = false;
  }

  /// Retries to connect again after a certain amount of time
  void _retry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 10), () {
      tryConnection();
    });
  }

  void connectionStopped() {
    connected.value = false;
    loading.value = true;
    error.value = "error.network".tr;
    _retry();
  }
}

/// Response for a try to connect to the server
class SetupResponse {
  final bool restart;
  final bool retryConnection;
  final String? error;

  SetupResponse({
    this.restart = false,
    this.retryConnection = false,
    this.error,
  });
}

abstract class ConnectionStep {
  final String name;
  ConnectionStep(this.name);

  /// bool: Should restart, String?: error
  Future<SetupResponse> load();
}
