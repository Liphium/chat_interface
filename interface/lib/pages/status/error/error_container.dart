import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ErrorContainer extends StatelessWidget {
  /// Translation required
  final String message;

  const ErrorContainer({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(defaultSpacing),
      decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(defaultSpacing)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          horizontalSpacing(defaultSpacing),
          Text(message, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class AnimatedErrorContainer extends StatefulWidget {
  /// Translation required
  final RxString message;
  final EdgeInsets padding;
  final bool expand;

  const AnimatedErrorContainer({
    super.key,
    required this.padding,
    required this.message,
    this.expand = false,
  });
  @override
  State<AnimatedErrorContainer> createState() => _AnimatedErrorContainerState();
}

class _AnimatedErrorContainerState extends State<AnimatedErrorContainer> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Animate(
        effects: [
          ExpandEffect(
            axis: Axis.vertical,
            curve: Curves.ease,
            duration: 250.ms,
          ),
        ],
        target: widget.message.value.isNotEmpty ? 1 : 0,
        child: Padding(
          padding: widget.padding,
          child: Container(
            padding: const EdgeInsets.all(defaultSpacing),
            decoration: BoxDecoration(color: Get.theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(defaultSpacing)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                horizontalSpacing(defaultSpacing),
                Flexible(
                  child: Text(widget.message.value, style: Theme.of(context).textTheme.labelMedium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedInfoContainer extends StatefulWidget {
  /// Translation required
  final RxString message;
  final EdgeInsets padding;
  final bool expand;

  const AnimatedInfoContainer({
    super.key,
    required this.padding,
    required this.message,
    this.expand = false,
  });
  @override
  State<AnimatedInfoContainer> createState() => _AnimatedInfoContainerState();
}

class _AnimatedInfoContainerState extends State<AnimatedInfoContainer> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Animate(
        effects: [
          ExpandEffect(
            axis: Axis.vertical,
            curve: Curves.ease,
            duration: 250.ms,
          ),
        ],
        target: widget.message.value.isNotEmpty ? 1 : 0,
        child: Padding(
          padding: widget.padding,
          child: Container(
            padding: const EdgeInsets.all(defaultSpacing),
            decoration: BoxDecoration(color: Get.theme.colorScheme.primary, borderRadius: BorderRadius.circular(defaultSpacing)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Icon(Icons.info, color: Theme.of(context).colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Flexible(
                  child: Text(widget.message.value, style: Theme.of(context).textTheme.labelMedium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
