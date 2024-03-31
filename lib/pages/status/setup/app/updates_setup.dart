import 'dart:io';

import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/util/logging_framework.dart';
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
    var location = await getApplicationDocumentsDirectory();
    location = Directory(path.join(location.path, "versions"));
    await location.create();

    // Check current version
    final entries = await location.list().toList();
    final currentName = path.basename(entries[0].path);

    final release = await fetchReleaseDataFor("Liphium", "chat_interface");
    if (release == null) {
      sendLog("Error with GitHub API, using current version");
      return null;
    }

    if (release.version != currentName) {
      // Update
      sendLog("should update");
      return const ShouldUpdateSetupPage();
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
  final res = await dio.get("https://api.github.com/repos/$owner/$repo/releases/latest");
  if (res.statusCode != 200) {
    return null;
  }

  print(res.data);

  return null;
}

class ShouldUpdateSetupPage extends StatelessWidget {
  const ShouldUpdateSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      body: Center(
        child: TransitionContainer(
          tag: "login",
          child: Text("hello world"),
        ),
      ),
    );
  }
}
