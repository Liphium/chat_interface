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
  static final vaultSyncTask = VaultSyncTask();

  /// Tasks that run after the setup
  final _tasks = <SynchronizationTask>[
    friendSyncTask,
    vaultSyncTask,
  ];
  bool tasksRan = false;

  /// Steps that run to get the client connected
  final _steps = <ConnectionStep>[];

  ConnectionController() {
    // Refresh the token and make sure it works
    _steps.add(RefreshTokenStep());

    // Get all the keys from the server (or generate new ones)
    _steps.add(KeySetup());

    // Get all the data about the account from the server
    _steps.add(AccountStep());

    // Connect to the server
    _steps.add(ConnectionSetup());

    // Process all stored actions from the server that haven't been processed yet
    _steps.add(StoredActionsSetup());
  }

  void tryConnection() async {
    // Initialize all the stuff
    for (var task in _tasks) {
      final result = await task.init();
      if (result != null) {
        error.value = "";
        error.value = result;
        _retry();
      }
    }

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

    // Start all the tasks
    for (var task in _tasks) {
      task.start();
    }
  }

  void _restart() {
    tasksRan = false;

    // Reset all data from the tasks before the restart
    for (var task in _tasks) {
      task.stop();
    }

    // Reset all previous state
    connected.value = false;
    loading.value = true;
    serverPublicKey = null;
    connector.disconnect();

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

  Timer? _timer;
  final loading = false.obs;

  /// Starts the task.
  void start() async {
    _timer = Timer.periodic(
      frequency,
      (timer) async {
        if (loading.value) {
          return;
        }
        loading.value = true;
        final result = await refresh();
        if (result != null) {
          sendLog("task $name finished with error: $result");
        }
        loading.value = false;
      },
    );
  }

  /// This method should initialize everything needed for the task.
  ///
  /// Returns an error if there is one.
  Future<String?> init();

  /// Stops the task.
  void stop() {
    _timer?.cancel();
    onRestart();
  }

  /// This method will be called every time in the loop.
  /// You can specify the duration of it using the [frequency] parameter in
  /// the constructor.
  ///
  /// Returns an error if there is one.
  Future<String?> refresh();

  /// This method should reset everything and prepare the task for a restart.
  void onRestart();
}
