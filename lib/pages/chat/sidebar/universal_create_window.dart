import 'package:chat_interface/pages/status/setup/smooth_dialog.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/space_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _CreateData {
  final IconData icon;
  final String title;
  final String description;
  final Widget Function() build;

  _CreateData({
    required this.icon,
    required this.title,
    required this.description,
    required this.build,
  });
}

class UniversalCreateWindow extends StatefulWidget {
  final ContextMenuData data;

  const UniversalCreateWindow({super.key, required this.data});

  @override
  State<UniversalCreateWindow> createState() => _UniversalCreateWindowState();
}

class _UniversalCreateWindowState extends State<UniversalCreateWindow>
    with TickerProviderStateMixin {
  /// All the different types of things that can be created
  late final _types = <_CreateData>[
    _CreateData(
      icon: Icons.public,
      title: "Square",
      description: "A place to hang out and chat.",
      build: () => ConversationAddWindow(position: null),
    ),
    _CreateData(
      icon: Icons.chat,
      title: "Conversation",
      description: "A regular conversation for chatting.",
      build: () => ConversationAddWindow(position: null),
    ),
    _CreateData(
      icon: Icons.rocket_launch,
      title: "Space",
      description: "Talk to your friends and have fun.",
      build: () => SpaceAddWindow(),
    ),
  ];

  late final SmoothDialogController _controller = SmoothDialogController(
    Padding(
      padding: const EdgeInsets.symmetric(vertical: dialogPadding),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${"create".tr}..", style: theme.textTheme.labelLarge),

              Column(
                children: List.generate(_types.length, (index) {
                  final data = _types[index];

                  return Padding(
                    padding: const EdgeInsets.only(top: defaultSpacing),
                    child: Material(
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      color: theme.colorScheme.inverseSurface,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        onTap: () {
                          _controller.transitionTo(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: dialogPadding),
                              child: data.build(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(defaultSpacing),
                          child: Row(
                            children: [
                              Icon(data.icon, size: 35, color: theme.colorScheme.onPrimary),
                              horizontalSpacing(defaultSpacing),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.title, style: theme.textTheme.labelMedium),
                                  verticalSpacing(elementSpacing),
                                  Text(data.description, style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    ),
    duration: Duration(milliseconds: 500),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingWindowBase(
      padding: 0,
      title: const [],
      position: widget.data,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: dialogPadding),
        child: SmoothBox(controller: _controller),
      ),
    );
  }
}
