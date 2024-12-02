import 'dart:async';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:get/get.dart';

class WarpController extends GetxController {
  final scanning = false.obs;
  final warps = <WarpShareContainer>[].obs;

  /// Start a port scan.
  ///
  /// This will start an isolate that then tries to connect to every port on the local system.
  Future<void> startScanning() async {
    scanning.value = true;

    scanning.value = false;
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
