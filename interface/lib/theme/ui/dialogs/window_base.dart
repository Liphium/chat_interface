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

class SlidingWindowBase extends StatelessWidget {

  final Offset position;
  final Widget child;

  const SlidingWindowBase({super.key, required this.position, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Animate(
            effects: [
              MoveEffect(
                begin: const Offset(0,-50),
                duration: 500.ms,
                curve: scaleAnimationCurve,
              )
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