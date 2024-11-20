import 'package:chat_interface/pages/settings/setting_selection_mobile.dart';
import 'package:chat_interface/pages/settings/settings_page_desktop.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsTabMobile extends StatefulWidget {
  const SettingsTabMobile({super.key});

  @override
  State<SettingsTabMobile> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsTabMobile> {
  @override
  Widget build(BuildContext context) {
    return PlatformCallback(
      desktop: () {
        Get.off(const SettingsPageDesktop());
      },
      child: Scaffold(
        backgroundColor: Get.theme.colorScheme.onInverseSurface,
        body: Material(
          color: Get.theme.colorScheme.onInverseSurface,
          child: const SingleChildScrollView(
            child: SafeArea(
              bottom: true,
              left: true,
              right: true,
              top: false,
              child: SettingSelectionMobile(),
            ),
          ),
        ),
      ),
    );
  }
}
