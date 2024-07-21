import 'package:chat_interface/controller/current/notification_controller.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/error_window.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

enum SnackbarType { success, error, warning, info }

extension SnackbarColorExtension on SnackbarType {
  Color get color {
    switch (this) {
      case SnackbarType.success:
        return Colors.green;
      case SnackbarType.error:
        return Colors.red;
      case SnackbarType.warning:
        return Colors.orange;
      case SnackbarType.info:
        return Colors.blue;
    }
  }
}

void showSnackbar(SnackbarType type, String title, String message) {
  Get.snackbar(
    title.tr,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.grey[900],
    colorText: Colors.white,
    margin: const EdgeInsets.all(8),
    borderRadius: 8,
    duration: const Duration(seconds: 3),
  );
}

void showMessage(SnackbarType type, String message) {
  Get.find<NotificationController>().set(type, message);
}

/// Automatically translated
void showErrorPopup(String title, String message) {
  Get.dialog(ErrorWindow(title: title.tr, error: translateError(message)));
}

Future<bool> showConfirmPopup(ConfirmWindow window) async {
  final result = await Get.dialog<bool>(window);
  if (result == null) {
    return true;
  }
  return result;
}

class NotificationRenderer extends StatefulWidget {
  final Offset position;

  const NotificationRenderer({super.key, this.position = const Offset(50, 20)});

  @override
  State<NotificationRenderer> createState() => _NotificationRendererState();
}

class _NotificationRendererState extends State<NotificationRenderer> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    NotificationController notificationController = Get.find();

    return Obx(() => Animate(
          target: notificationController.open.value ? 1 : 0,
          effects: [
            ScaleEffect(curve: Curves.elasticOut, duration: 400.ms, begin: const Offset(0, 0)),
            FadeEffect(curve: Curves.linear, duration: 250.ms, delay: 100.ms, begin: 0),
          ],
          child: Positioned(
              top: widget.position.dx,
              right: widget.position.dy,
              child: SizedBox(
                  width: 350,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    child: Material(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        child: Row(
                          children: [
                            Obx(
                              () => Container(
                                width: 5,
                                height: 30,
                                color: notificationController.type.value.color,
                              ),
                            ),
                            horizontalSpacing(defaultSpacing),
                            Expanded(
                              child: Obx(() => Text(
                                    notificationController.message.value,
                                    style: theme.textTheme.bodyLarge,
                                  )),
                            )
                          ],
                        )),
                  ))),
        ));
  }
}
