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
    if (!checkVersion) {
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
    final entries = await location.list().toList();
    if (entries.isEmpty) {
      // Update
      sendLog("update required");
      return ShouldUpdateSetupPage(data: release);
    }
    final currentName = path.basename(entries[0].path);
    sendLog(currentName);

    if (release.version != currentName) {
      // Update
      sendLog("should update");
      return ShouldUpdateSetupPage(data: release, prev: currentName);
    }

    return null;
  }
}

class ReleaseData {
  final String version;
  final String body;
  final String downloadUrl;

  ReleaseData(this.version, this.body, this.downloadUrl);
}

Future<ReleaseData?> fetchReleaseDataFor(String owner, String repo) async {
  final res = await dio.get("https://api.github.com/repos/$owner/$repo/releases/latest", options: Options(validateStatus: (s) => true));
  if (res.statusCode != 200) {
    return null;
  }

  var searchTerm = "linux.zip";
  if (Platform.isWindows) {
    searchTerm = "windows.zip";
  } else if (Platform.isMacOS) {
    searchTerm = "macos.zip";
  }

  for (var asset in res.data["assets"]) {
    if (asset["name"] == searchTerm) {
      sendLog(asset);
      return ReleaseData(res.data["tag_name"], res.data["body"], asset["browser_download_url"]);
    }
  }

  return null;
}

Future<bool> updateApp(RxString status, ReleaseData data, {String? prev}) async {
  try {
    if (Platform.isWindows && !executableArguments.contains("--update")) {
      status.value = "Re-running with admin privilege..";
      restartProcessAsAdmin(status);
      await Future.delayed(3.seconds);
      exit(0);
    }

    var location = await getApplicationSupportDirectory();
    location = Directory(path.join(location.path, "versions"));

    final res = await dio.download(
      data.downloadUrl,
      path.join(location.path, "download.zip"),
      onReceiveProgress: (count, total) {
        status.value = "Downloading ${((count / total) * 100.0).toStringAsFixed(0)}%..";
      },
      options: Options(
        validateStatus: (status) => true,
      ),
    );

    if (res.statusCode != 200) {
      status.value = "Couldn't download from GitHub";
      return false;
    }

    status.value = "Extracting..";
    final dir = await Directory(path.join(location.path, data.version)).create();
    await extractFileToDisk(path.join(location.path, "download.zip"), dir.path, asyncWrite: true);

    status.value = "Deleting old files..";
    if (prev != null) {
      await Directory(path.join(location.path, prev)).delete(recursive: true);
    }
    await File(path.join(location.path, "download.zip")).delete();

    final linkDir = path.join(getDesktopDirectory().path, "Liphium");
    final link = Link(linkDir);
    if (link.existsSync()) {
      await File(linkDir).delete();
    }
    if (Platform.isWindows) {
      await link.create(path.join(location.path, data.version, "chat_interface.exe"));
    } else if (Platform.isMacOS) {
      await link.create(path.join(location.path, data.version, "chat_interface.dmg"));
    } else if (Platform.isLinux) {
      await link.create(path.join(location.path, data.version, "chat_interface"));
      Process.run("chmod", ["+x", path.join(location.path, data.version, "chat_interface")]);
      status.value = "Since you are on Linux, you might have to give the executable we just downloaded for you some permissions.";
      await Future.delayed(30.seconds);
    }

    status.value =
        "Update completed, thanks for your patience! There should be a Desktop shortcut, just click that to restart Liphium and you'll hopefully not be downloading an update again.";
    return true;
  } catch (e) {
    status.value = "There was an error during the update: $e";
    return false;
  }
}

void restartProcessAsAdmin(RxString status) async {
  sendLog(Platform.resolvedExecutable);
  final result = await Process.run(
    'powershell',
    ['Start-Process "${Platform.resolvedExecutable}" -ArgumentList "--update" -Verb RunAs'],
  );
  status.value = result.exitCode.toString() + result.stdout.toString() + result.stderr.toString();
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
  final String? prev;
  final ReleaseData data;

  const ShouldUpdateSetupPage({super.key, required this.data, this.prev});

  @override
  State<ShouldUpdateSetupPage> createState() => _ShouldUpdateSetupPageState();
}

class _ShouldUpdateSetupPageState extends State<ShouldUpdateSetupPage> {
  @override
  void initState() {
    super.initState();
    updateApp(status, widget.data, prev: widget.prev);
  }

  final status = "While you wait, you might as well go touch some grass.".obs;

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
                Text("Updating..", style: Get.theme.textTheme.headlineMedium),
                verticalSpacing(sectionSpacing),
                Obx(() => Text(status.value, style: Get.theme.textTheme.labelLarge)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
