import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liphium_desktop/liphium_desktop.dart';

class DesktopManager extends StatelessWidget {
  final Widget child;

  const DesktopManager({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CloseToTray(
      showWindowText: "tray.show_window".tr,
      exitAppText: "tray.exit_app".tr,
      child: child,
    );
  }
}
