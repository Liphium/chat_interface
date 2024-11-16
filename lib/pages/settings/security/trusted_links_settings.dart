import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrustedLinkSettings {
  static const String unsafeSources = "links.unsafe_sources";
  static const String trustMode = "links.trust_mode";

  static const trustModes = [
    SelectableItem("links.trust_mode.all", Icons.share),
    SelectableItem("links.trust_mode.list", Icons.sort),
    SelectableItem("links.trust_mode.none", Icons.close),
  ];

  static void registerSettings(SettingController controller) {
    controller.addSetting(Setting<bool>(unsafeSources, false));
    controller.addSetting(Setting<int>(trustMode, 1));
  }
}

class TrustedLinkSettingsPage extends StatefulWidget {
  const TrustedLinkSettingsPage({super.key});

  @override
  State<TrustedLinkSettingsPage> createState() => _TrustedLinkSettingsPageState();
}

class _TrustedLinkSettingsPageState extends State<TrustedLinkSettingsPage> {
  final _trusted = <TrustedLinkData>[].obs;

  @override
  void initState() {
    super.initState();
    loadTrusted();
  }

  void loadTrusted() async {
    _trusted.value = await db.trustedLink.select().get();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "trusted_links",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoContainer(
            message: "links.warning".tr,
            expand: true,
          ),
          verticalSpacing(sectionSpacing),

          //* Location trust types
          Text("links.locations".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          // Unsafe locations
          const BoolSettingSmall(
            settingName: TrustedLinkSettings.unsafeSources,
          ),
          verticalSpacing(sectionSpacing),

          Text("links.trusted_domains".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          // Trust mode
          Text("links.trust_mode".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          const ListSelectionSetting(
            settingName: TrustedLinkSettings.trustMode,
            items: TrustedLinkSettings.trustModes,
          ),
          verticalSpacing(sectionSpacing),

          Text("links.trusted_list".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          FJElevatedButton(
            onTap: () async {
              final result = await showModal(const TrustedLinkCreationWindow());
              final data = TrustedLinkData(domain: result);
              db.trustedLink.insertOnConflictUpdate(data);
              _trusted.add(data);
            },
            child: Text("links.trusted_list.add".tr, style: Get.theme.textTheme.labelLarge),
          ),
          verticalSpacing(defaultSpacing),
          Obx(() {
            if (_trusted.isEmpty) {
              return Text("links.trusted_list.empty".tr, style: Get.theme.textTheme.labelMedium);
            }

            return Column(
              children: List.generate(
                _trusted.length,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: elementSpacing),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: elementSpacing),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.onInverseSurface,
                        borderRadius: BorderRadius.circular(defaultSpacing),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Icon(Icons.done_all, color: Get.theme.colorScheme.onPrimary),
                                horizontalSpacing(defaultSpacing),
                                Flexible(
                                  child: Text(
                                    _trusted[index].domain,
                                    style: Get.theme.textTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              db.trustedLink.deleteWhere((tbl) => tbl.domain.equals(_trusted[index].domain));
                              _trusted.removeAt(index);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class TrustedLinkCreationWindow extends StatefulWidget {
  const TrustedLinkCreationWindow({super.key});

  @override
  State<TrustedLinkCreationWindow> createState() => _TrustedLinkCreationWindowState();
}

class _TrustedLinkCreationWindowState extends State<TrustedLinkCreationWindow> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Text("links.trusted_list.add".tr, style: Get.theme.textTheme.titleMedium),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FJTextField(
            controller: _controller,
            hintText: "links.trusted_list.placeholder".tr,
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedButton(
            onTap: () => Get.back(result: _controller.text),
            child: Center(
              child: Text("add".tr, style: Get.theme.textTheme.labelLarge),
            ),
          )
        ],
      ),
    );
  }
}
