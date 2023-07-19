import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class TransitionContainer extends StatefulWidget {

  final Color? color;
  final double? width;
  final BorderRadius? borderRadius;
  final Widget child;
  final String tag;

  const TransitionContainer(
      {super.key, required this.child, required this.tag, this.borderRadius, this.color, this.width});

  @override
  State<TransitionContainer> createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<TransitionContainer> {

  @override
  Widget build(BuildContext context) {
    return GetX<TransitionController>(
      builder: (controller) {
        return Hero(
          tag: widget.tag,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              color: widget.color ?? Theme.of(context).colorScheme.onBackground,
            ),
            child: Animate(
              target: controller.transitionOut.value ? 0 : 1,
              effects: [
                ScaleEffect(
                  duration: controller.transitionDuration,
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  curve: const ElasticOutCurve(0.9),
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
