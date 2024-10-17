library liphium_desktop;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

export 'tray_icon_widget.dart';

void initDesktopWindow() async {
  if (isDesktopPlatform()) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(300, 500));
    await windowManager.setTitle("Liphium");
    await windowManager.setAlignment(Alignment.center);
  }
}

bool isDesktopPlatform() {
  if (kIsWeb || kIsWasm) {
    return false;
  }
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
