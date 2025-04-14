import 'package:chat_interface/pages/status/setup/smooth_dialog.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UniversalCreateWindow extends StatefulWidget {
  final ContextMenuData data;

  const UniversalCreateWindow({super.key, required this.data});

  @override
  State<UniversalCreateWindow> createState() => _UniversalCreateWindowState();
}

class _UniversalCreateWindowState extends State<UniversalCreateWindow>
    with TickerProviderStateMixin {
  final SmoothDialogController _controller = SmoothDialogController(
    Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("create".tr, style: theme.textTheme.labelLarge),
            verticalSpacing(sectionSpacing),
            Material(
              color: theme.colorScheme.inverseSurface,
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.public),
                    horizontalSpacing(defaultSpacing),
                    Text("Square", style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingWindowBase(
      title: const [],
      position: widget.data,
      child: SmoothBox(controller: _controller),
    );
  }
}
