import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/account/data_settings.dart';
import 'package:chat_interface/services/chat/status_service.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/forms/lph_action_fields.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/profile/developer_window.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class OwnProfileMobile extends StatefulWidget {
  const OwnProfileMobile({super.key});

  @override
  State<OwnProfileMobile> createState() => _OwnProfileMobileState();
}

class _OwnProfileMobileState extends State<OwnProfileMobile> {
  // Developer things
  var _clicks = 0;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return DevicePadding(
      top: true,
      right: true,
      left: true,
      padding: EdgeInsets.all(defaultSpacing * 1.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("About your profile", style: Get.textTheme.titleMedium),
          verticalSpacing(defaultSpacing * 1.5),

          SizedBox(
            height: 60 + defaultSpacing * 2 + 14,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(defaultSpacing),
                  ),
                  height: 60 + defaultSpacing * 2,
                  padding: const EdgeInsets.all(defaultSpacing),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          children: [UserAvatar(id: StatusController.ownAddress, size: 60)],
                        ),
                      ),
                      horizontalSpacing(sectionSpacing),
                      Expanded(
                        child: Text(
                          StatusController.name.value,
                          overflow: TextOverflow.ellipsis,
                          style: Get.theme.textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingIconButton(
                        onTap: () {
                          _clicks++;
                          if (_clicks > 7) {
                            showModal(const DeveloperWindow());
                          }
                          Clipboard.setData(ClipboardData(text: StatusController.name.value));
                        },
                        background: true,
                        backgroundColor: Get.theme.colorScheme.primary,
                        color: Get.theme.colorScheme.onPrimary,
                        icon: Icons.copy,
                      ),
                      horizontalSpacing(defaultSpacing),
                      LoadingIconButton(
                        onTap: () => Get.to(DataSettingsPage()),
                        icon: Icons.edit,
                        background: true,
                        backgroundColor: Get.theme.colorScheme.primary,
                        color: Get.theme.colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),
          LPHCopyField(label: "liphium_address".tr, value: StatusController.ownAddress.toString()),
          verticalSpacing(defaultSpacing),

          //* Status
          Watch((ctx) {
            if (StatusController.ownContainer.value != null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: elementSpacing),
                child: ProfileButton(
                  icon: Icons.stop,
                  label: 'profile.stop_sharing'.tr,
                  onTap: () => StatusController.stopSharing(),
                ),
              );
            }

            if (SpaceController.connected.value) {
              return Padding(
                padding: const EdgeInsets.only(bottom: elementSpacing),
                child: ProfileButton(
                  icon: Icons.start,
                  label: 'profile.start_sharing'.tr,
                  onTap: () => StatusController.share(SpaceController.getContainer()),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          verticalSpacing(defaultSpacing),

          //* Current status type
          Text("Set your status", style: Get.textTheme.titleMedium),
          verticalSpacing(defaultSpacing * 1.5),
          RepaintBoundary(
            child: Watch((ctx) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(4, (index) {
                  // Get details
                  Color color = getStatusColor(theme, index);
                  IconData icon = getStatusIcon(index);
                  final bool selected = StatusController.type.value == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: defaultSpacing),
                    child: Material(
                      color:
                          selected ? theme.colorScheme.primary : theme.colorScheme.inverseSurface,
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        onTap: () async {
                          final error = await StatusService.sendStatus(type: index);
                          if (error != null) {
                            showErrorPopup("error", error);
                            return;
                          }
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(defaultSpacing),
                          child: Row(
                            children: [
                              //* Status icon
                              Icon(icon, size: 13.0, color: color),
                              horizontalSpacing(defaultSpacing),
                              Text(
                                "status.${index.toString()}".tr,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color:
                                      selected
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.surface,
                                ),
                                textHeightBehavior: noTextHeight,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}
