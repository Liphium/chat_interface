import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:liphium_desktop/liphium_desktop.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

bool _isTrayInitalized = false;

class CloseToTray extends StatefulWidget {
  /// The translated version of the show window text
  final String? showWindowText;

  /// The translated version of the exit app text
  final String? exitAppText;

  final Widget child;

  const CloseToTray({
    super.key,
    required this.child,
    this.showWindowText,
    this.exitAppText,
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
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  /// Adds Liphium to the tray
  void initTray() async {
    if (_isTrayInitalized) {
      return;
    }
    _isTrayInitalized = true;
    await trayManager.setIcon(Platform.isWindows
        ? "packages/liphium_desktopR/assets/icon_windows.ico"
        : Platform.isMacOS
            ? "packages/liphium_desktop/assets/icon_macos.png"
            : "packages/liphium_desktop/assets/icon_linux.png");
    await trayManager.setToolTip("Liphium");
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(
            key: "show_window",
            label: widget.showWindowText ?? "Show window",
          ),
          MenuItem(
            key: "exit_app",
            label: widget.exitAppText ?? "Exit app",
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
  Widget build(BuildContext context) {
    return widget.child;
  }
}
