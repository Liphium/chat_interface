import 'dart:io';

import 'package:chat_interface/pages/settings/components/double_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/pages/status/setup/app/instance_setup.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LogManager {
  static Directory? loggingDirectory;
  static File? currentLogFile;

  /// Deletes all current log files except for the current one.
  static void deleteAllLogs() async {
    for (var file in await loggingDirectory!.list().toList()) {
      if (file.path == currentLogFile!.path) {
        continue;
      }
      await file.delete();
    }
  }

  /// Enables logging if not currently enabled.
  ///
  /// Returns whether anything changed (if it was successful).
  static Future<bool> enableLogging() async {
    if (currentLogFile != null) {
      return false;
    }

    // Set the logging directory
    loggingDirectory = Directory(path.join((await getApplicationSupportDirectory()).path, "logs_$currentInstance"));
    await loggingDirectory!.create();

    // Initialize the newest log file
    currentLogFile = File(path.join(loggingDirectory!.path, "log-${DateTime.now().toUtc().toString().replaceAll(" ", "_").replaceAll(":", "-").split(".")[0]}.txt"));
    await currentLogFile!.create();

    return true;
  }

  /// Log a normal line to the file (if logging is enabled).
  static Future<bool> addLog(String line) async {
    if (currentLogFile == null) {
      return false;
    }
    currentLogFile!.writeAsStringSync("${DateTime.now().toUtc()}: $line\n", mode: FileMode.append, flush: true);
    return true;
  }

  /// Log an error to the file (if logging is enabled).
  static void addError(Object error, StackTrace? trace) {
    if (currentLogFile == null) {
      return;
    }
    error.printError(info: "error", logFunction: _errorLogFunction);
    trace?.printError(info: "stack", logFunction: _errorLogFunction);
  }

  /// Custom log function copied from GetUtils.printFunction to write things to the file too
  static void _errorLogFunction(String prefix, dynamic value, String info, {isError = false}) {
    currentLogFile!.writeAsStringSync("${DateTime.now().toUtc()}: ${isError ? "error" : "info"}: ${value.toString()} ($info) \n", mode: FileMode.append);
  }
}

class LogSettings {
  static String amountOfLogs = "logging.amount";

  static void registerSettings(SettingController controller) {
    controller.settings[amountOfLogs] = Setting<double>(amountOfLogs, 5);
  }
}

class LogSettingsPage extends StatelessWidget {
  const LogSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "logging",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoubleSelectionSetting(
            settingName: LogSettings.amountOfLogs,
            description: "logging.amount.desc",
            rounded: true,
            min: 1,
            max: 30,
          ),
          verticalSpacing(elementSpacing),
          FJElevatedButton(
            onTap: () => OpenAppFile.open(LogManager.loggingDirectory!.path),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.launch,
                  color: Get.theme.colorScheme.onPrimary,
                ),
                horizontalSpacing(elementSpacing),
                Text(
                  "logging.launch".tr,
                  style: Get.textTheme.labelLarge,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
