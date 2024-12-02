import 'dart:async';
import 'dart:io';

import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';

class WarpController extends GetxController {
  // Port scanning
  final scanning = false.obs;
  final availablePorts = <int>[].obs;
  final _startPort = 1024;
  final _endPort = 65535;

  /// Start a port scan.
  ///
  /// This will start an isolate that then tries to connect to every port on the local system.
  Future<void> startScanning() async {
    scanning.value = true;

    // Scan through all TCP ports quickly by scanning 25 at a time
    for (var start = _startPort; start <= _endPort; start += 25) {
      // Scan the actual ports and add them to a list of futures
      final futures = <Future>[];
      for (var i = start; i <= start + 25; i++) {
        if (i > _endPort) {
          break;
        }
        sendLog("scanning $i..");
        try {
          futures.add(_scanIndividual(i));
        } catch (_) {}
      }

      // Get all the ports from the futures and add the available ones
      final ports = await Future.wait(futures);
    }

    scanning.value = false;
  }

  /// Scans an individual port on localhost for a TCP server.
  Future<int> _scanIndividual(int port) async {
    try {
      Socket socket = await Socket.connect("localhost", port);
      unawaited(socket.close());
      return port;
    } catch (_) {}
    return -1;
  }
}
