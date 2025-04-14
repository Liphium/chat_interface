import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/town/admin_accounts_page.dart';
import 'package:chat_interface/pages/status/setup/smooth_dialog.dart';
import 'package:chat_interface/theme/components/forms/lph_action_fields.dart';
import 'package:chat_interface/theme/components/lph_tab_element.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class AdminAccountProfile extends StatefulWidget {
  final AccountData account;

  const AdminAccountProfile({super.key, required this.account});

  @override
  State<AdminAccountProfile> createState() => _AdminAccountProfileState();
}

class _AdminAccountProfileState extends State<AdminAccountProfile> {
  late SmoothDialogController _controller;

  final _currentTab = signal("settings.acc_profile.tab.info".tr);
  late Map<String, Widget Function()> _tabs;

  @override
  void dispose() {
    _currentTab.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabs = <String, Widget Function()>{
      "settings.acc_profile.tab.info".tr:
          () => Column(
            children: [
              // Fields for copying all the account data
              LPHCopyField(label: "settings.acc_profile.info.id".tr, value: widget.account.id),
              verticalSpacing(defaultSpacing),
              LPHCopyField(
                label: "settings.acc_profile.info.email".tr,
                value: widget.account.email,
              ),
              verticalSpacing(defaultSpacing),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: LPHCopyField(
                      label: "settings.acc_profile.info.username".tr,
                      value: widget.account.username,
                    ),
                  ),
                  horizontalSpacing(defaultSpacing),
                  Expanded(
                    child: LPHCopyField(
                      label: "settings.acc_profile.info.display_name".tr,
                      value: widget.account.displayName,
                    ),
                  ),
                ],
              ),
            ],
          ),
      "settings.acc_profile.tab.actions".tr:
          () => Column(
            children: [
              LPHActionField(
                primary: "rank".tr,
                secondary:
                    StatusController.ranks
                        .firstWhere((rank) => rank.id == widget.account.rankID)
                        .name,
                actions: [
                  LPHActionData(
                    icon: Icons.edit,
                    tooltip: "edit".tr,
                    onClick:
                        () => Get.dialog(
                          ChangeRankWindow(data: widget.account, onUpdate: acceptUpdate),
                        ),
                  ),
                ],
              ),
            ],
          ),
    };

    _controller = SmoothDialogController(_tabs[_currentTab.value]!());
    super.initState();
  }

  void acceptUpdate(AccountData data) {
    _controller.transitionToContinuos(_tabs[_currentTab.value]!());
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
        ),
      ],
      maxWidth: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LPHTabElement(
            tabs: ["settings.acc_profile.tab.info".tr, "settings.acc_profile.tab.actions".tr],
            onTabSwitch: (tab) {
              _currentTab.value = tab;
              _controller.transitionToContinuos(_tabs[tab]!());
            },
          ),
          verticalSpacing(defaultSpacing),
          SmoothBox(controller: _controller),
        ],
      ),
    );
  }
}

class ChangeRankWindow extends StatefulWidget {
  final AccountData data;
  final Function(AccountData) onUpdate;

  const ChangeRankWindow({super.key, required this.data, required this.onUpdate});

  @override
  State<ChangeRankWindow> createState() => _ChangeRankWindowState();
}

class _ChangeRankWindowState extends State<ChangeRankWindow> {
  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [Text("rank".tr, style: Get.textTheme.labelLarge)],
      child: Column(
        children: [
          Text("settings.rank_change.desc".tr, style: Get.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          Text(
            "Rank updates can take up to two days because of current system limitations. This will be resolved with protocol v6.",
            style: Get.textTheme.bodyMedium,
          ),
          verticalSpacing(elementSpacing),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(StatusController.ranks.length, (index) {
              final rank = StatusController.ranks[index];

              return Padding(
                padding: const EdgeInsets.only(top: defaultSpacing),
                child: Material(
                  color: Get.theme.colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    onTap: () async {
                      final json = await postAuthorizedJSON("/townhall/accounts/change_rank", {
                        "account": widget.data.id,
                        "rank": rank.id,
                      });

                      if (!json["success"]) {
                        showErrorPopup("error", json["error"]);
                        return;
                      }

                      // Update the rank in the UI
                      widget.data.rankID = rank.id;
                      widget.onUpdate(widget.data);

                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(defaultSpacing),
                      child: Row(
                        children: [
                          Icon(Icons.military_tech, color: Get.theme.colorScheme.onPrimary),
                          horizontalSpacing(defaultSpacing),
                          Text("${rank.name} (${rank.level})", style: Get.textTheme.labelLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
