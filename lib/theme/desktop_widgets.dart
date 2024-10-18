import 'dart:io';

import 'package:chat_interface/main.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

bool _isTrayInitalized = false;

class CloseToTray extends StatefulWidget {
  final Widget child;

  const CloseToTray({
    super.key,
    required this.child,
  });

  @override
  State<CloseToTray> createState() => _CloseToTrayState();
}

class _CloseToTrayState extends State<CloseToTray> with WindowListener, TrayListener {
  @override
  void initState() {
    if (isDesktopPlatform()) {
      // Init all the features of the tray
      initTray();

      // Add the listener to listen to window and tray events
      windowManager.addListener(this);
      trayManager.addListener(this);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (isDesktopPlatform()) {
      windowManager.removeListener(this);
      trayManager.removeListener(this);
    }
    super.dispose();
  }

  /// Adds Liphium to the tray
  void initTray() async {
    if (_isTrayInitalized) {
      return;
    }
    _isTrayInitalized = true;
    await trayManager.setIcon(Platform.isWindows
        ? "assets/tray/icon_windows.ico"
        : Platform.isMacOS
            ? "assets/tray/icon_macos.png"
            : "assets/tray/icon_linux.png");
    await trayManager.setToolTip("Liphium");
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(
            key: "show_window",
            label: "tray.show_window".tr,
            onClick: (item) {
              windowManager.show();
            },
          ),
          MenuItem(
            key: "exit_app",
            label: "tray.exit_app".tr,
            onClick: (item) {
              exit(0);
            },
          ),
        ],
      ),
    );
  }

  // Make sure the context menu opens when the tray icon is clicked
  @override
  void onTrayIconMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onWindowClose() async {
    await windowManager.setPreventClose(true);
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}