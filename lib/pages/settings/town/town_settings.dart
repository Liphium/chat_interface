import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/account/key_requests_window.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/pages/status/setup/server_setup.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class TownSettingsPage extends StatefulWidget {
  const TownSettingsPage({super.key});

  @override
  State<TownSettingsPage> createState() => _TownSettingsPageState();
}

class _TownSettingsPageState extends State<TownSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "spaces",
      child: Column(
        children: [
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
        ],
      ),
    );
  }
}
