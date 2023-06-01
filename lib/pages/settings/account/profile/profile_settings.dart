import 'dart:convert';

import 'package:chat_interface/pages/settings/account/profile/profile_settings_status.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/ui/text_renderer/text_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {

  final loading = true.obs;
  final error = Rx<String?>("error.offline");
  final enabled = false.obs;

  @override
  void initState() {

    loadProfile();
    super.initState();
  }

  void loadProfile() async {
    
    // Request data from server
    final res = await postRqAuthorized("/account/profile/me", <String, dynamic>{});
    loading.value = false;

    if(res.statusCode != 200) {
      return;
    }

    final body = jsonDecode(res.body);
    if(!body["success"]) {
      error.value = body["error"];
      return;
    }

    enabled.value = body["enabled"];
    error.value = null;
  }
 
  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //* Title
        Padding(
          padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 1.5),
          child: Text("settings.categories.profile".tr, style: theme.textTheme.headlineMedium),
        ),
        verticalSpacing(defaultSpacing),

        //* Text renderer test
        const TextRenderer(text: "~This is a **bold** text, this is an *italic* text, this is an _underline_ text.~"),

        //* Status indicator
        Obx(() =>
          loading.value ? 
          const Center(child: CircularProgressIndicator()) :

          error.value != null ?
          ErrorContainer(
            message: "error.${error.value!}".tr, 
            description: "error.${error.value!}.text".tr
          ) :

          ProfileSettingsStatus(enabled: enabled)
        ),
      ],
    );
  }
}