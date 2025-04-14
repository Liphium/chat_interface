import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:signals/signals_flutter.dart';

class OfflineHider extends StatelessWidget {
  final EdgeInsets? padding;
  final Axis axis;
  final Widget child;
  final Alignment alignment;

  const OfflineHider({
    super.key,
    required this.axis,
    required this.child,
    required this.alignment,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Watch(
      (ctx) => Animate(
        effects: [
          ExpandEffect(axis: axis, curve: Curves.ease, duration: 250.ms, alignment: alignment),
          FadeEffect(duration: 250.ms),
        ],
        target: ConnectionController.connected.value ? 1 : 0,
        onInit: (controller) => controller.value = ConnectionController.connected.value ? 1 : 0,
        child: Padding(padding: padding ?? EdgeInsets.all(0), child: child),
      ),
    );
  }
}
