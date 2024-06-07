import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/settings_frame.dart';
import 'package:chat_interface/pages/settings/settings_page_mobile.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsHomepage extends StatefulWidget {
  const SettingsHomepage({super.key});

  @override
  State<SettingsHomepage> createState() => _SettingsHomepageState();
}

class _SettingsHomepageState extends State<SettingsHomepage> {
  final currentCategory = Rx<SettingCategory?>(null);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Use mobile version on mobile
      if (isMobileMode()) {
        return const SettingsPageMobile();
      }

      return const SettingsDesktopFrame();
    });
  }
}
