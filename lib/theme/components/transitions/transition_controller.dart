import 'dart:async';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class TransitionController extends GetxController {
  final transitionDuration = 250.ms; // constant
  final transition = false.obs;

  Timer? currentTimer;

  void cancelAll() {
    transition.value = false;
    currentTimer?.cancel();
  }

  void modelTransition(dynamic page) {
    transitionTo(page, (page) => Get.offAll(page, transition: Transition.fade));
  }

  void transitionTo(dynamic page, Function(dynamic) goTo) {
    // Reset the state
    currentTimer?.cancel();
    transition.value = true;

    // Start a timer to give the hero element time to fade out
    currentTimer = Timer(transitionDuration, () {
      goTo(page);

      currentTimer = Timer(transitionDuration, () {
        transition.value = false;
      });
    });
  }
}
