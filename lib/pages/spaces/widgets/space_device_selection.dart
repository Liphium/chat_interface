import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class SpaceDeviceSelection extends StatelessWidget {
  final String title;
  final Widget child;
  final ContextMenuData data;

  const SpaceDeviceSelection({
    super.key,
    required this.title,
    required this.child,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlidingWindowBase(
      title: const [],
      position: data,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          child,
        ],
      ),
    );
  }
}
