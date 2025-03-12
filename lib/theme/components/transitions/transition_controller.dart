import 'dart:async';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class TransitionController extends GetxController {
  static final transitionDuration = 250.ms; // constant
  static final transition = false.obs;

  static Timer? _currentTimer;

  static void cancelAll() {
    transition.value = false;
    _currentTimer?.cancel();
  }

  /// Transition to a new page
  static void transitionTo(dynamic page, Function(dynamic) goTo) {
    // Reset the state
    _currentTimer?.cancel();
    transition.value = true;

    // Start a timer to give the hero element time to fade out
    _currentTimer = Timer(transitionDuration, () {
      goTo(page);

      _currentTimer = Timer(transitionDuration, () {
        transition.value = false;
      });
    });
  }
}
