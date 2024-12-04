import 'dart:async';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/pages/spaces/warp/warp_manager_window.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:get/get.dart';

class WarpController extends GetxController {
  final scanning = false.obs;

  /// Warps that are currently available (not connected) according to the server.
  final warps = <WarpShareContainer>[].obs;

  /// Warps that the user is connected to.
  final activeWarps = <WarpShareContainer>[].obs;

  /// Connect to a Warp using its container.
  ///
  /// This will start an isolate that then tries to connect to every port on the local system.
  Future<void> connectToWarp(WarpShareContainer container) async {
    scanning.value = true;

    scanning.value = false;
  }

  /// Open Warp based on what it's currently doing.
  void open() {
    showModal(WarpManagerWindow());
  }
}

class WarpShareContainer {
  /// The id of the Warp (mainly used for identification)
  final String id;

  /// The port of the Warp.
  final int port;

  /// The person sharing the Warp.
  final Friend account;

  WarpShareContainer(this.id, this.account, this.port);
}
