import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class UpdateSetup extends Setup {
  UpdateSetup() : super('loading.update', false);

  @override
  Future<Widget?> load() async {
    if (!checkVersion || isDebug) {
      return null;
    }

    var location = await getApplicationSupportDirectory();
    location = Directory(path.join(location.path, "versions/"));
    await location.create();

    final release = await fetchReleaseDataFor("Liphium", "chat_interface");
    if (release == null) {
      sendLog("Error with GitHub API, using current version");
      return null;
    }

    // Check current version
    final entities = await location.list().toList();
    if (entities.isEmpty) {
      // Update
      sendLog("install required");
      return _updatePage(release);
    }

    // Delete any leftover stuff
    bool downloadFile = false;
    if (entities.length >= 2) {
      for (var entity in entities) {
        final name = path.basename(entity.path);
        if (name.endsWith(".zip")) {
          downloadFile = true;
        }
      }
    }

    // Find the current version
    bool found = false;
    int versionsFound = 0;
    for (var entity in entities) {
      final name = path.basename(entity.path);
      final type = await FileSystemEntity.type(entity.path);
      if (type == FileSystemEntityType.directory) {
        versionsFound++;
      }
      if (name == release.version) {
        found = true;
      }
    }

    // Check if installation is needed
    if (versionsFound > 1 || downloadFile) {
      return _installPage(release);
    }

    if (found) {
      return null;
    }
    return _updatePage(release);
  }
}

Widget _updatePage(ReleaseData data) {
  return ShouldUpdateSetupPage(
    title: "Updating..",
    callback: (value, data) {
      updateApp(value, data);
    },
    data: data,
  );
}

Widget _installPage(ReleaseData data) {
  return ShouldUpdateSetupPage(
    title: "Installing..",
    callback: (value, data) {
      installApp(value, data);
    },
    data: data,
  );
}

class ReleaseData {
  final String version;
  final String body;
  final String downloadUrl;

  ReleaseData(this.version, this.body, this.downloadUrl);
}

/// Install the current version of the app
void installApp(RxString status, ReleaseData data) async {
  String step = "admin";
  try {
    // Run with admin privilege on windows
    if (Platform.isWindows && !executableArguments.contains("--update")) {
      restartProcessAsAdmin();
      await Future.delayed(3.seconds);
      exit(0);
    }

    // Wait for the other process to exit (potentially)
    status.value = "Preparing..";
    await Future.delayed(const Duration(seconds: 5));

    // Get the path for the general support folder
    final location = await getApplicationSupportDirectory();

    // Delete older versions
    status.value = "Cleaning up..";
    step = "del old versions";
    final versionsDir = Directory(path.join(location.path, "versions"));
    for (var version in (await versionsDir.list().toList())) {
      final type = await FileSystemEntity.type(version.path);
      if (type == FileSystemEntityType.directory) {
        if (path.basename(version.path) != data.version) {
          step = "del ${path.basename(version.path)}";
          // Try to delete, otherwise return an error
          await version.delete(recursive: true);
        }
      }

      // Delete the download.zip file (and any others cause doesn't matter)
      if (version.path.endsWith(".zip")) {
        await version.delete();
      }
    }

    // Create an application shortcut (for the start menu)
    status.value = "Adding app..";
    step = "add to start";
    if (GetPlatform.isWindows) {
      final shortcutPath = path.join("C:/ProgramData/Microsoft/Windows/Start Menu/Programs", "Liphium.lnk");
      final shortcutFile = File(shortcutPath);
      if (await shortcutFile.exists()) {
        step = "delete current";
        await shortcutFile.delete();
      }

      // Execute a powershell command to create a shortcut (dart doesn't have support for this..)
      step = "execute powershell command";
      final powerShellCommand = '''
        \$targetPath = "${path.join(location.path, "versions", data.version, "chat_interface.exe")}"
        \$shortcutPath = "$shortcutPath"
        \$wshShell = New-Object -ComObject WScript.Shell
        \$shortcut = \$wshShell.CreateShortcut(\$shortcutPath)
        \$shortcut.TargetPath = \$targetPath
        \$shortcut.Save()
        ''';

      final result = await Process.run(
        'powershell',
        ['-Command', powerShellCommand],
      );

      if (result.exitCode != 0) {
        status.value = "Shortcut couldn't be created (${result.exitCode})";
      }
    } else if (GetPlatform.isLinux) {
      // TODO: Make compatible with Linux
    }

    // Restart the setup
    await Future.delayed(const Duration(seconds: 3));
    setupManager.restart();
  } catch (e) {
    status.value = "Error during installation ($step): $e";
  }
}

/// Get the release data for a project from GitHub
Future<ReleaseData?> fetchReleaseDataFor(String owner, String repo) async {
  final res = await dio.get("https://api.github.com/repos/$owner/$repo/releases/latest", options: Options(validateStatus: (s) => true));
  if (res.statusCode != 200) {
    return null;
  }

  var searchTerm = "linux.zip";
  if (Platform.isWindows) {
    searchTerm = "windows.zip";
  }

  for (var asset in res.data["assets"]) {
    if (asset["name"] == searchTerm) {
      sendLog(asset);
      return ReleaseData(res.data["tag_name"], res.data["body"], asset["browser_download_url"]);
    }
  }

  return null;
}

/// Download and extract the executable as well as add it to the versions folder
Future<bool> updateApp(RxString status, ReleaseData data) async {
  try {
    // Run with admin privilege on windows
    if (Platform.isWindows && !executableArguments.contains("--update")) {
      status.value = "Re-running with admin privilege..";
      await restartProcessAsAdmin();
      exit(0);
    }

    // Wait quickly
    status.value = "Preparing..";
    await Future.delayed(const Duration(seconds: 5));

    // Get the path for the versions folder
    var location = await getApplicationSupportDirectory();
    location = Directory(path.join(location.path, "versions"));

    // Download the version
    final res = await dio.download(
      data.downloadUrl,
      path.join(location.path, "download.zip"),
      onReceiveProgress: (count, total) {
        status.value = "Downloading ${((count / total) * 100.0).toStringAsFixed(1)}%..";
      },
      options: Options(
        validateStatus: (status) => true,
      ),
    );

    // Check if download was successful
    if (res.statusCode != 200) {
      status.value = "Couldn't download from GitHub";
      return false;
    }

    // Extract the downloaded archive into the versions folder
    status.value = "Extracting..";
    final dir = await Directory(path.join(location.path, data.version)).create();
    await extractFileToDisk(path.join(location.path, "download.zip"), dir.path, asyncWrite: true);

    // Restart the app
    status.value = "Restarting..";

    if (GetPlatform.isWindows) {
      // Search for the executable
      final directory = Directory(path.join(location.path, data.version));
      final entities = await directory.list().toList();
      late final FileSystemEntity executable;
      for (var entity in entities) {
        if (path.basename(entity.path).endsWith(".exe")) {
          executable = entity;
        }
      }

      sendLog("restarting with path: ${executable.path}");
      await restartProcessAsAdmin(path: executable.path);
    } else if (GetPlatform.isLinux) {
      // TODO: Fix the linux updater
    }

    exit(0);
  } catch (e) {
    status.value = "There was an error during the update: $e";
    return false;
  }
}

Future<bool> restartProcessAsAdmin({String? path}) async {
  sendLog(Platform.resolvedExecutable);
  await Process.run(
    'powershell',
    ['Start-Process "${path ?? Platform.resolvedExecutable}" -ArgumentList "--update" -Verb RunAs'],
  );
  return true;
}

Directory getDesktopDirectory() {
  String home = "";
  Map<String, String> envVars = Platform.environment;
  if (Platform.isMacOS) {
    home = envVars['HOME']!;
  } else if (Platform.isLinux) {
    home = envVars['HOME']!;
  } else if (Platform.isWindows) {
    home = envVars["UserProfile"]!;
    final exists = Directory(path.join(home, "Desktop")).existsSync();
    if (!exists) {
      home = path.join(home, "OneDrive");
    }
  }

  return Directory(path.join(home, "Desktop"));
}

class ShouldUpdateSetupPage extends StatefulWidget {
  final String title;
  final Function(RxString, ReleaseData data) callback;
  final ReleaseData data;

  const ShouldUpdateSetupPage({
    super.key,
    required this.title,
    required this.callback,
    required this.data,
  });

  @override
  State<ShouldUpdateSetupPage> createState() => _ShouldUpdateSetupPageState();
}

class _ShouldUpdateSetupPageState extends State<ShouldUpdateSetupPage> {
  @override
  void initState() {
    super.initState();
    widget.callback.call(_status, widget.data);
  }

  final _status = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: Center(
        child: TransitionContainer(
          borderRadius: BorderRadius.circular(modelBorderRadius),
          tag: "login",
          width: 370,
          child: Padding(
            padding: const EdgeInsets.all(sectionSpacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 1000),
                Text(widget.title, style: Get.theme.textTheme.headlineMedium),
                verticalSpacing(sectionSpacing),
                Obx(
                  () => Text(_status.value, style: Get.theme.textTheme.labelLarge),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
