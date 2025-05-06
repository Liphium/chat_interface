import 'dart:async';

import 'package:chat_interface/services/connection/connection.dart';
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
import 'package:signals/signals_flutter.dart';

class ConnectionController {
  static final loading = signal(false);
  static final connected = signal(false);
  static final error = signal("");
  static Timer? _retryTimer;

  // Static tasks so their loading state can be accessed from anywhere
  static final friendSyncTask = FriendsSyncTask();
  static final vaultSyncTask = VaultSyncTask();

  /// Tasks that run after the setup
  static Timer? _taskRunner;
  static final _tasks = <SynchronizationTask>[friendSyncTask, vaultSyncTask];
  static bool tasksRan = false;

  /// Steps that run to get the client connected
  static final _steps = <ConnectionStep>[];

  static void init() {
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

  static Future<void> tryConnection() async {
    // Initialize all the stuff
    for (var task in _tasks) {
      sendLog("initializing task ${task.name}..");
      final result = await task.init();
      if (result != null) {
        error.value = "";
        error.value = result;
        sendLog("task ${task.name} failed during initialization: $result");
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
        restart();
        return;
      }

      // If a retry is requested, retry all setups
      if (result.retryConnection) {
        await Future.delayed(500.ms); // To prevent CPU overuse in case of a bug (hopefully never happens)
        unawaited(tryConnection());
        return;
      }
    }

    // Run everything that needs to happen after connected
    connector.runAfterSetupQueue();
    connected.value = true;
    error.value = "";
    loading.value = false;

    unawaited(_startTasks());
  }

  static Future<void> _startTasks() async {
    if (tasksRan) return;
    tasksRan = true;

    // Create an inline function for running the tasks
    Future<void> runTasks() async {
      for (var task in _tasks) {
        sendLog("running sync task ${task.name}..");
        final error = await task.run();
        if (error != null) {
          sendLog("task ${task.name} finished with error: $error");
        }
      }
    }

    // Start the task runner
    _taskRunner = Timer.periodic(Duration(seconds: 30), (timer) => runTasks());
    await runTasks();
  }

  static void restart() {
    tasksRan = false;

    // Reset all data from the tasks before the restart
    _taskRunner?.cancel();
    for (var task in _tasks) {
      task.onRestart();
    }

    // Reset all previous state
    connected.value = false;
    loading.value = true;
    serverPublicKey = null;
    connector.disconnect();

    setupManager.retry();
  }

  /// Retries to connect again after a certain amount of time
  static void _retry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 10), () {
      tryConnection();
    });
  }

  static void connectionStopped() {
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

  SetupResponse({this.restart = false, this.retryConnection = false, this.error});
}

abstract class ConnectionStep {
  final String name;
  ConnectionStep(this.name);

  /// This method should load everything related to this step.
  Future<SetupResponse> load();
}

abstract class SynchronizationTask {
  final String name;

  SynchronizationTask(this.name);

  final loading = signal(false);

  /// Run an interation of the task.
  ///
  /// Returns an error if there was one.
  Future<String?> run() async {
    if (loading.value) {
      return "loading".tr;
    }
    loading.value = true;
    final result = await refresh();
    loading.value = false;
    return result;
  }

  /// This method should initialize everything needed for the task.
  ///
  /// Returns an error if there is one.
  Future<String?> init();

  /// This method will be called every time in the loop.
  ///
  /// Returns an error if there is one.
  Future<String?> refresh();

  /// This method should reset everything and prepare the task for a restart.
  void onRestart();
}
