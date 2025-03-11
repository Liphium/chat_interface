import 'dart:async';

import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ErrorContainer extends StatelessWidget {
  /// Translation required
  final String message;
  final bool expand;

  const ErrorContainer({
    super.key,
    required this.message,
    this.expand = false,
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
          if (expand)
            Expanded(child: Text(message, style: Theme.of(context).textTheme.labelMedium))
          else
            Text(message, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class InfoContainer extends StatelessWidget {
  /// Translation required
  final String message;
  final bool expand;

  const InfoContainer({
    super.key,
    required this.message,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(defaultSpacing),
      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(defaultSpacing)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: Theme.of(context).colorScheme.onPrimary),
          horizontalSpacing(defaultSpacing),
          if (expand)
            Expanded(child: Text(message, style: Theme.of(context).textTheme.labelMedium))
          else
            Text(message, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class AnimatedErrorContainer extends StatefulWidget {
  /// Translation required
  final Signal<String> message;
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

class _AnimatedErrorContainerState extends State<AnimatedErrorContainer> with SignalsMixin {
  final message = signal("");
  final showing = signal(false);
  AnimationController? controller;
  String? prev;

  @override
  void initState() {
    effect(() {
      final msg = widget.message.value;
      if (prev != null && prev != "" && msg != "") {
        controller?.loop(count: 1, reverse: true);
      }
      if (msg != "") {
        message.value = msg;
        showing.value = true;
        prev = msg;
      } else {
        showing.value = false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (ctx) => Animate(
        effects: [
          ScaleEffect(
            duration: 250.ms,
            curve: Curves.ease,
            begin: const Offset(1.1, 1.1),
            end: const Offset(1.0, 1.0),
          ),
        ],
        onInit: (controller) => this.controller = controller,
        child: Animate(
          effects: [
            ExpandEffect(
              axis: Axis.vertical,
              curve: Curves.ease,
              duration: 250.ms,
            ),
          ],
          target: showing.value ? 1 : 0,
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
                    child: Text(message.value, style: Theme.of(context).textTheme.labelMedium),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedInfoContainer extends StatefulWidget {
  /// Translation required
  final Signal<String> message;
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
  final message = "".obs;
  final showing = false.obs;
  AnimationController? controller;
  StreamSubscription<String>? _sub;
  String? prev;

  @override
  void initState() {
    effect(() {
      final msg = widget.message.value;
      if (prev != null && prev != "" && msg != "") {
        controller?.loop(count: 1, reverse: true);
      }
      if (msg != "") {
        message.value = msg;
        showing.value = true;
        prev = msg;
      } else {
        showing.value = false;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Animate(
        effects: [
          ScaleEffect(
            duration: 250.ms,
            curve: Curves.ease,
            begin: const Offset(1.1, 1.1),
            end: const Offset(1.0, 1.0),
          ),
        ],
        onInit: (controller) => this.controller = controller,
        child: Animate(
          effects: [
            ExpandEffect(
              axis: Axis.vertical,
              curve: Curves.ease,
              duration: 250.ms,
            ),
          ],
          target: showing.value ? 1 : 0,
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
                  Icon(Icons.error, color: Theme.of(context).colorScheme.onPrimary),
                  horizontalSpacing(defaultSpacing),
                  Flexible(
                    child: Text(message.value, style: Theme.of(context).textTheme.labelMedium),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
