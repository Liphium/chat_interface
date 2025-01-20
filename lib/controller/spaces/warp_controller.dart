import 'dart:async';

import 'package:chat_interface/services/spaces/warp/warp_connection.dart';
import 'package:chat_interface/services/spaces/warp/warp_service.dart';
import 'package:chat_interface/services/spaces/warp/warp_shared.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/pages/spaces/warp/warp_manager_window.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:get/get.dart';
import 'package:signals/signals.dart';

class WarpController {
  static bool loading = false;

  /// Ports the current user is sharing as Warps
  static final sharedWarps = signal(<String, SharedWarp>{});

  /// Warps that the user is connected to.
  static final activeWarps = signal(<String, ConnectedWarp>{});

  /// Warps that are currently available (not connected) according to the server.
  static final warps = signal(<WarpShareContainer>[]);

  static void resetControllerState() {
    // Stop all the Warps
    for (var warp in sharedWarps.value.values) {
      warp.stop(action: false);
    }
    for (var warp in activeWarps.value.values) {
      warp.disconnectFromWarp(action: false);
    }

    // Delete all the state
    batch(() {
      warps.value.clear();
      sharedWarps.value.clear();
      activeWarps.value.clear();
    });
    loading = false;
  }

  /// Create a Warp using the port it should share.
  static Future<String?> createWarp(int port) async {
    // Create a Warp using the service
    final (error, warp) = await WarpService.createWarp(port);
    if (error != null) {
      return error;
    }

    // Add the Warp to the list of shared warps
    assert(warp != null);
    sharedWarps.value[warp!.id] = warp;
    return null;
  }

  /// Stop a Warp and remove it from the list of shared Warps.
  void stopWarp(SharedWarp warp) {
    warp.stop();
    sharedWarps.value.remove(warp.id);
  }

  /// Connect to a Warp using its container.
  ///
  /// This will start an isolate that then tries to connect to every port on the local system.
  static Future<void> connectToWarp(WarpShareContainer container) async {
    if (loading) {
      return;
    }
    container.loading.value = true;
    loading = true;

    // Connect to the Warp using the service
    final warp = await WarpService.connectToWarp(container);
    activeWarps.value[warp.id] = warp;

    container.loading.value = false;
    loading = false;
  }

  /// Completely disconnect a Warp
  static void disconnectWarp(ConnectedWarp warp) {
    warp.disconnectFromWarp();
    activeWarps.value.remove(warp.id);
  }

  /// This method gets called when a Warp ends according to the server.
  static void onWarpEnd(String warp) {
    // Start a batch to make sure there is only one update
    batch(() {
      // Disconnect if an active warp is closed
      if (activeWarps.value.containsKey(warp)) {
        activeWarps.value[warp]!.disconnectFromWarp(action: false);
        activeWarps.value.remove(warp);
      }

      // Remove it from the list of Warps on the server
      warps.value.removeWhere((w) => w.id == warp);
    });
  }

  /// Open Warp based on what it's currently doing.
  static void open() {
    showModal(WarpManagerWindow());
  }

  /// Add a shared warp from the server to the list on the client.
  static void addWarp(WarpShareContainer container) {
    warps.value.add(container);
  }

  /// Get a currently active Warp
  static ConnectedWarp? getActiveWarp(String id) {
    return activeWarps.value[id];
  }

  /// Get a currently shared Warp
  static SharedWarp? getSharedWarp(String id) {
    return sharedWarps.value[id];
  }

  /// Remove currently active warp
  static void removeActiveWarp(ConnectedWarp warp) {
    activeWarps.value.remove(warp.id);
  }
}

/// A container for a Warp that's being shared in a Space.
class WarpShareContainer {
  /// The id of the Warp (mainly used for identification)
  final String id;

  /// The port of the Warp.
  final int port;

  /// The person sharing the Warp.
  final Friend account;

  final loading = false.obs;

  WarpShareContainer({
    required this.id,
    required this.account,
    required this.port,
  });
}
