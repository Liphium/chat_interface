import 'dart:async';

import 'package:chat_interface/util/snackbar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final open = false.obs;
  final type = SnackbarType.info.obs;
  final message = ''.obs;

  var timer = Timer(1000.ms, () {});

  void set(SnackbarType type, String message) {
    timer.cancel();
    timer = Timer(2000.ms, () {
      open.value = false;
    });

    open.value = true;
    this.type.value = type;
    this.message.value = message;
  }
}
