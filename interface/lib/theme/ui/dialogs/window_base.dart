import 'dart:math' as math;

import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class WindowBase extends StatelessWidget {

  final Offset position;
  final Widget child;

  const WindowBase({super.key, required this.position, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: child,
        ),
      ],
    );
  }
}

class DialogBase extends StatelessWidget {

  final Widget child;
  final double maxWidth;

  const DialogBase({super.key, required this.child, this.maxWidth = 300});

  @override
  Widget build(BuildContext context) {

    final random = math.Random();
    final randomOffset = random.nextDouble() * 8 + 5;
    final randomHz = random.nextDouble() * 1 + 1;

    return Center(
      child: Animate(
        effects: [
          ScaleEffect(
            delay: 100.ms,
            duration: 500.ms,
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            alignment: Alignment.center,
            curve: const ElasticOutCurve(0.8)
          ),
          ShakeEffect(
            delay: 100.ms,
            duration: 400.ms,
            hz: randomHz,
            offset: Offset(random.nextBool() ? randomOffset : -randomOffset, random.nextBool() ? randomOffset : -randomOffset),
            rotation: 0,
            curve: Curves.decelerate
          ),
          FadeEffect(
            delay: 100.ms,
            duration: 250.ms,
            curve: Curves.easeOut
          )
        ],
        target: 1,
        child: Material(
          elevation: 2.0,
          color: Get.theme.colorScheme.onBackground,
          borderRadius: BorderRadius.circular(dialogBorderRadius),
          child: Container(
            width: maxWidth,
            padding: const EdgeInsets.all(dialogPadding),
            child: child
          ),
        )
      ),
    );
  }
}

class SlidingWindowBase extends StatelessWidget {

  final Offset position;
  final Widget child;

  const SlidingWindowBase({super.key, required this.position, required this.child});

  @override
  Widget build(BuildContext context) {

    final random = math.Random();
    final randomOffset = random.nextDouble() * 3 + 2;
    final randomHz = random.nextDouble() * 1 + 1.5;

    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Animate(
            effects: [
              MoveEffect(
                duration: 400.ms,
                begin: const Offset(0, -100),
                curve: scaleAnimationCurve
              ),
              ShakeEffect(
                duration: 350.ms,
                hz: randomHz,
                offset: Offset(random.nextBool() ? randomOffset : -randomOffset, random.nextBool() ? randomOffset : -randomOffset),
                rotation: 0,
                curve: Curves.decelerate
              ),
            ],
            target: 1,
            child: SizedBox(
              width: 300,
              child: Material(
                elevation: 2.0,
                color: Get.theme.colorScheme.onBackground,
                borderRadius: BorderRadius.circular(dialogBorderRadius),
                child: Padding(
                  padding: const EdgeInsets.all(dialogPadding),
                  child: child,
                )
              )
            )
          ),
        ),
      ],
    );
  }
}