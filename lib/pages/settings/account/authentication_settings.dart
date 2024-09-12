import 'package:chat_interface/pages/settings/account/change_password_window.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthenticationSettingsPage extends StatefulWidget {
  const AuthenticationSettingsPage({super.key});

  @override
  State<AuthenticationSettingsPage> createState() => _AuthenticationSettingsPageState();
}

class _AuthenticationSettingsPageState extends State<AuthenticationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "authentication",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* First factor
          Text("settings.authentication.first_factor".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          buildChangeContainer(Icons.password, "password", () => showModal(const ChangePasswordWindow())),
          verticalSpacing(defaultSpacing),

          buildChangeContainer(Icons.hub, "sso", () => showModal(const ChangePasswordWindow())),
          verticalSpacing(sectionSpacing),

          //* Second factor
          Text("settings.authentication.second_factor".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          buildChangeContainer(Icons.qr_code, "totp", () => showModal(const ChangePasswordWindow())),
          verticalSpacing(defaultSpacing),

          buildChangeContainer(Icons.mail, "email", () => showModal(const ChangePasswordWindow())),
          verticalSpacing(sectionSpacing),
        ],
      ),
    );
  }

  Widget buildChangeContainer(IconData icon, String name, Function() change) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(sectionSpacing),
      ),
      padding: const EdgeInsets.all(sectionSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Get.theme.colorScheme.onPrimary),
                    horizontalSpacing(defaultSpacing),
                    Text("settings.authentication.$name".tr, style: Get.theme.textTheme.labelMedium),
                  ],
                ),
                verticalSpacing(elementSpacing),
                Text("settings.authentication.$name.desc".tr, style: Get.theme.textTheme.bodyMedium),
              ],
            ),
          ),
          horizontalSpacing(defaultSpacing),
          FJElevatedButton(
            smallCorners: true,
            onTap: change,
            child: Text("change".tr, style: Get.theme.textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}
