import 'package:chat_interface/pages/settings/setting_selection_mobile.dart';
import 'package:chat_interface/theme/ui/containers/universal_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPageMobile extends StatefulWidget {
  const SettingsPageMobile({super.key});

  @override
  State<SettingsPageMobile> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPageMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: SafeArea(
        child: Column(
          children: [
            UniversalAppBar(label: "app.settings".tr),
            const Expanded(
              child: SingleChildScrollView(
                child: SidebarMobile(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}