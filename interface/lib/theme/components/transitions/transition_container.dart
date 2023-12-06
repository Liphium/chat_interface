import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class TransitionContainer extends StatefulWidget {

  final Color? color;
  final double? width;
  final BorderRadius? borderRadius;
  final Widget child;
  final String tag;
  final bool fade;

  const TransitionContainer(
      {super.key, required this.child, required this.tag, this.borderRadius, this.color, this.width, this.fade = false});

  @override
  State<TransitionContainer> createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<TransitionContainer> {

  @override
  Widget build(BuildContext context) {

    Effect<dynamic> mainEffect;
    
    if(widget.fade) {
      mainEffect = FadeEffect(
        duration: 500.ms,
        begin: 0,
        end: 1,
      );
    } else {
      mainEffect = ScaleEffect(
        duration: 500.ms,
        begin: const Offset(0, 0),
        end: const Offset(1, 1),
        curve: scaleAnimationCurve
      );
    }

    return GetX<TransitionController>(
      builder: (controller) {
        return IgnorePointer(
          ignoring: controller.transition.value,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              color: widget.color ?? Theme.of(context).colorScheme.onBackground,
            ),
            child: Animate(
              target: controller.transition.value ? 0 : 1,
              effects: [
                mainEffect,
                ExpandEffect(
                  duration: 250.ms,
                  axis: Axis.vertical,
                  alignment: Alignment.center,
                )
              ],
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
