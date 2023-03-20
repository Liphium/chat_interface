import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:chat_interface/controller/current/notification_controller.dart' as nc;
import 'package:flutter_animate/flutter_animate.dart';

class NotificationRenderer extends StatelessWidget {

  final nc.Notification notification;

  const NotificationRenderer({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: defaultSpacing),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(defaultSpacing),
          child: Container(
            padding: const EdgeInsets.all(defaultSpacing),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              border: Border(
                left: BorderSide(
                  color: notification.type.color,
                  width: 5,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: Text(notification.message, style: const TextStyle(color: Colors.white), softWrap: true)),
                horizontalSpacing(defaultSpacing * 2)
              ],
            ),
          ).animate().custom(
            duration: 300.ms,
            builder: (context, value, child) => Container(
              color: Color.lerp(Colors.red, Colors.blue, value),
              padding: const EdgeInsets.all(8),
              child: child, // child is the Text widget being animated
            )
          )
        ),
      ),
    );
  }
}