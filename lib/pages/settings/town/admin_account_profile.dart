import 'package:chat_interface/pages/settings/town/admin_accounts_page.dart';
import 'package:chat_interface/pages/status/setup/smooth_dialog.dart';
import 'package:chat_interface/theme/components/forms/lph_copy_field.dart';
import 'package:chat_interface/theme/components/lph_tab_element.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAccountProfile extends StatefulWidget {
  final AccountData account;

  const AdminAccountProfile({
    super.key,
    required this.account,
  });

  @override
  State<AdminAccountProfile> createState() => _AdminAccountProfileState();
}

class _AdminAccountProfileState extends State<AdminAccountProfile> {
  late SmoothDialogController controller;

  final currentTab = "settings.acc_profile.tab.info".tr.obs;
  late Map<String, Widget> tabs;

  @override
  void initState() {
    tabs = <String, Widget>{
      "settings.acc_profile.tab.info".tr: Column(
        children: [
          LPHCopyField(label: "settings.acc_profile.info.id".tr, value: widget.account.id),
          verticalSpacing(defaultSpacing),
          LPHCopyField(label: "settings.acc_profile.info.email".tr, value: widget.account.email),
          verticalSpacing(defaultSpacing),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: LPHCopyField(label: "settings.acc_profile.info.username".tr, value: widget.account.username)),
              horizontalSpacing(defaultSpacing),
              Expanded(child: LPHCopyField(label: "settings.acc_profile.info.display_name".tr, value: widget.account.displayName)),
            ],
          ),
        ],
      ),
      "settings.acc_profile.tab.actions".tr: Column(
        children: [
          Text("Coming soon", style: Get.textTheme.labelLarge),
        ],
      ),
    };

    controller = SmoothDialogController(tabs[currentTab.value]!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Text(
          "settings.acc_profile.title".trParams({
            "name": "${widget.account.displayName} (${widget.account.username})",
          }),
          style: Get.textTheme.labelLarge,
        )
      ],
      maxWidth: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LPHTabElement(
            tabs: [
              "settings.acc_profile.tab.info".tr,
              "settings.acc_profile.tab.actions".tr,
            ],
            onTabSwitch: (tab) {
              controller.transitionToContinuos(tabs[tab]!);
            },
          ),
          verticalSpacing(defaultSpacing),
          SmoothBox(
            controller: controller,
          ),
        ],
      ),
    );
  }
}
