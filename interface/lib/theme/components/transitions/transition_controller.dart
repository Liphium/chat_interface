import 'dart:async';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class TransitionController extends GetxController {
  final transitionDuration = 250.ms; // constant
  final transition = false.obs;

  Timer? currentTimer;

  void modelTransition(dynamic page) {
    transitionTo(page, (page) => Get.offAll(page, transition: Transition.noTransition));
  }

  void transitionTo(dynamic page, Function(dynamic) goTo) {
    if (currentTimer != null) {
      currentTimer!.cancel();
    }

    transition.value = true;

    currentTimer = Timer(transitionDuration, () {
      goTo(page);

      currentTimer = Timer(transitionDuration, () {
        transition.value = false;
      });
    });
  }
}
