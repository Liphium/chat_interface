import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/pages/settings/town/town_admin_settings.dart';
import 'package:chat_interface/pages/status/setup/server_setup.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TownSettingsPage extends StatefulWidget {
  const TownSettingsPage({super.key});

  @override
  State<TownSettingsPage> createState() => _TownSettingsPageState();
}

class _TownSettingsPageState extends State<TownSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "town",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Info about the current town
          Text("settings.town.info".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          Container(
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
                      Text("settings.town.own_town".tr, style: Get.theme.textTheme.labelMedium),
                      verticalSpacing(elementSpacing),
                      Text(
                        "settings.town.own_town.desc".trParams({
                          "domain": basePath,
                          "version": apiVersion,
                          "protocol": protocolVersion.toString(),
                        }),
                        style: Get.theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),
          Container(
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
                      Text("settings.town.address".tr, style: Get.theme.textTheme.labelMedium),
                      verticalSpacing(elementSpacing),
                      Text(
                        "settings.town.address.desc".trParams(),
                        style: Get.theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                FJElevatedButton(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: StatusController.ownAddress.encode()),
                    );
                    showSuccessPopup("success", "settings.town.address.copied".tr);
                  },
                  child: Text("copy".tr, style: Get.textTheme.labelMedium),
                ),
              ],
            ),
          ),
          verticalSpacing(sectionSpacing),

          // Show a little extra category just for directing them to the docs
          Text("settings.town.help".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          Text("settings.town.help.desc".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing + elementSpacing),
          FJElevatedButton(
            onTap: () => launchUrlString(Constants.docsAdminBase),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.launch, color: Get.theme.colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Text("help".tr, style: Get.theme.textTheme.labelLarge),
              ],
            ),
          ),
          verticalSpacing(sectionSpacing),

          if (StatusController.permissions.contains("admin")) const TownAdminSettings(),
        ],
      ),
    );
  }
}
