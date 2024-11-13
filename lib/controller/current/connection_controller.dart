import 'dart:async';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/controller/current/steps/connection_step.dart';
import 'package:chat_interface/controller/current/tasks/friend_sync_task.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/controller/current/steps/profile_step.dart';
import 'package:chat_interface/controller/current/steps/stored_actions_step.dart';
import 'package:chat_interface/controller/current/tasks/vault_sync_task.dart';
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

  // Static tasks so their loading state can be accessed from anywhere
  static final friendSyncTask = FriendsSyncTask();

  /// Tasks that run after the setup
  final _tasks = <SynchronizationTask>[
    friendSyncTask,
  ];
  bool tasksRan = false;

  /// Steps that run to get the client connected
  final _steps = <ConnectionStep>[];

  ConnectionController() {
    //* Steps that run to get everything to set up

    // Refresh the token and make sure it works
    _steps.add(RefreshTokenStep());

    // Get all the keys from the server (or generate new ones)
    _steps.add(KeySetup());

    // Get all the data about the account from the server
    _steps.add(AccountSetup());

    // Process all stored actions from the server that haven't been processed yet
    _steps.add(StoredActionsSetup());

    // Connect to the server
    _steps.add(ConnectionSetup());

    //* Steps that can be ran after the setup

    // Load all the friends from the server vault
    _tasks.add(FriendsSyncTask());

    // Load all conversations and stuff from the vault
    _tasks.add(VaultSyncTask());
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
        _restart();
        return;
      }

      // If a retry is requested, retry all setups
      if (result.retryConnection) {
        await Future.delayed(500.ms); // To prevent CPU overuse in case of a bug (hopefully never happens)
        tryConnection();
        return;
      }
    }

    // Run everything that needs to happen after connected
    connector.runAfterSetupQueue();
    connected.value = true;
    error.value = "";
    loading.value = false;

    _startTasks();
  }

  void _startTasks() async {
    if (tasksRan) return;
    tasksRan = true;

    // TODO: Run all the synchronization tasks
  }

  void _restart() {
    tasksRan = false;
    setupManager.retry();
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

  /// This method should load everything related to this step.
  Future<SetupResponse> load();
}

abstract class SynchronizationTask {
  final String name;
  final Duration frequency;

  SynchronizationTask(this.name, this.frequency);

  bool loading = false;

  /// This method should load everything related to this step.
  ///
  /// Returns an error if there is one.
  Future<String?> refresh();

  void onRestart();
}
