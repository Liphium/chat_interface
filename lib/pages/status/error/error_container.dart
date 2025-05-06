import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ErrorContainer extends StatelessWidget {
  /// Translation required
  final String message;
  final bool expand;

  const ErrorContainer({super.key, required this.message, this.expand = false});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(defaultSpacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(defaultSpacing),
      ),
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

  const InfoContainer({super.key, required this.message, this.expand = false});

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

class _AnimatedContainerBase extends StatefulWidget {
  /// Translation required
  final Signal<String> message;
  final EdgeInsets padding;
  final bool expand;
  final Color iconColor;
  final Color backgroundColor;

  const _AnimatedContainerBase({
    super.key,
    required this.padding,
    required this.message,
    required this.iconColor,
    required this.backgroundColor,
    this.expand = false,
  });
  @override
  State<_AnimatedContainerBase> createState() => _AnimatedContainerBaseState();
}

class _AnimatedContainerBaseState extends State<_AnimatedContainerBase> with SignalsMixin {
  // For handling the animation
  AnimationController? controller;
  String? prev;

  // State
  late final _message = createSignal("");
  late final _showing = createSignal(false);

  @override
  void initState() {
    createEffect(() {
      final msg = widget.message.value;
      if (prev != null && prev != "" && msg != "") {
        controller?.loop(count: 1, reverse: true);
      }
      if (msg != "") {
        _message.value = msg;
        _showing.value = true;
        prev = msg;
      } else {
        _showing.value = false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ScaleEffect(duration: 250.ms, curve: Curves.ease, begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0)),
      ],
      onInit: (controller) => this.controller = controller,
      child: Animate(
        effects: [ExpandEffect(axis: Axis.vertical, curve: Curves.ease, duration: 250.ms)],
        target: _showing.value ? 1 : 0,
        child: Padding(
          padding: widget.padding,
          child: Container(
            padding: const EdgeInsets.all(defaultSpacing),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(defaultSpacing),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                horizontalSpacing(defaultSpacing),
                Flexible(child: Text(_message.value, style: Theme.of(context).textTheme.labelMedium)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedErrorContainer extends StatelessWidget {
  /// Translation required
  final Signal<String> message;
  final EdgeInsets padding;
  final bool expand;

  const AnimatedErrorContainer({super.key, required this.padding, required this.message, this.expand = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _AnimatedContainerBase(
      key: key,
      padding: padding,
      message: message,
      iconColor: theme.colorScheme.error,
      backgroundColor: theme.colorScheme.errorContainer,
      expand: expand,
    );
  }
}

class AnimatedInfoContainer extends StatelessWidget {
  /// Translation required
  final Signal<String> message;
  final EdgeInsets padding;
  final bool expand;

  const AnimatedInfoContainer({super.key, required this.padding, required this.message, this.expand = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _AnimatedContainerBase(
      key: key,
      padding: padding,
      message: message,
      iconColor: theme.colorScheme.onPrimary,
      backgroundColor: theme.colorScheme.primary,
      expand: expand,
    );
  }
}
