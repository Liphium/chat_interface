import 'dart:io';

import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../util/vertical_spacing.dart';
import 'setup_manager.dart';

const agreeFile = ".agreements";

class PolicySetup extends Setup {
  PolicySetup() : super('loading.policy', true);

  @override
  Future<Widget?> load() async {
    // Check when the file was created
    final supportDir = await getApplicationSupportDirectory();
    var file = File(path.join(supportDir.path, agreeFile));
    final exists = await file.exists();
    if (exists) {
      final lastModified = await file.lastModified();

      // Return if already checked in the last 7 days
      if (lastModified.add(const Duration(days: 7)).isAfter(DateTime.now())) {
        return null;
      }
    }

    // Check the current version on the server
    final res = await dio.get("https://liphium.com/legal/terms");
    if (res.statusCode != 200) {
      sendLog("ERROR ${res.statusCode}");
      return null;
    }

    // Set a new last access date
    if (exists) {
      await file.setLastModified(DateTime.now());
    }

    // Get the version from the html
    final response = res.data.toString();
    final splittedAtLast = response.split("last updated:");
    final uncoveredDate = splittedAtLast[1].substring(1, 11);

    // Check if the agreements file has already been created and contains the latest date
    file = File(path.join(supportDir.path, agreeFile));
    if (!file.existsSync()) {
      return PolicyAcceptPage(
        versionToWrite: uncoveredDate,
      );
    }
    final content = await file.readAsString();
    if (content.trim() != uncoveredDate) {
      return PolicyAcceptPage(
        versionToWrite: uncoveredDate,
      );
    }

    return null;
  }
}

class PolicyAcceptPage extends StatefulWidget {
  final String versionToWrite;

  const PolicyAcceptPage({super.key, required this.versionToWrite});

  @override
  State<PolicyAcceptPage> createState() => _PolicyAcceptPageState();
}

class _PolicyAcceptPageState extends State<PolicyAcceptPage> with SignalsMixin {
  final error = signal("");
  final clicked = signal(false);
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'setup.policy'.tr,
          style: Get.textTheme.headlineMedium,
        ),
        verticalSpacing(sectionSpacing),
        Text("setup.policy.text".tr, style: Get.textTheme.bodyMedium),
        verticalSpacing(sectionSpacing),
        AnimatedErrorContainer(
          padding: const EdgeInsets.only(bottom: defaultSpacing),
          message: error,
          expand: true,
        ),
        FJElevatedButton(
          onTap: () async {
            const url = "https://liphium.com/legal/terms";
            if (await canLaunchUrl(Uri.parse(url))) {
              final result = await launchUrl(Uri.parse(url));
              if (result) {
                clicked.value = true;
                return;
              }
            }
            error.value = "setup.policy.error".tr;
          },
          child: Center(
            child: Text(
              "View agreements",
              style: Get.textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Obx(
          () => Animate(
            effects: [
              ExpandEffect(
                axis: Axis.vertical,
                curve: scaleAnimationCurve,
                duration: 500.ms,
              ),
              FadeEffect(
                duration: 500.ms,
              )
            ],
            target: clicked.value ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.only(top: defaultSpacing),
              child: FJElevatedButton(
                onTap: () async {
                  final supportDir = await getApplicationSupportDirectory();

                  // Add a file to document that the privacy policy has been accepted
                  final file = await File(path.join(supportDir.path, agreeFile)).create();
                  await file.writeAsString(widget.versionToWrite);
                  await setupManager.next();
                },
                child: Center(child: Text("accept".tr, style: Get.textTheme.labelLarge)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
