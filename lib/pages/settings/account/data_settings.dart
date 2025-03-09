import 'dart:async';

import 'package:chat_interface/controller/account/profile_picture_helper.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/account/change_display_name_window.dart';
import 'package:chat_interface/pages/settings/account/change_name_window.dart';
import 'package:chat_interface/pages/settings/account/log_out_window.dart';
import 'package:chat_interface/pages/settings/account/key_requests_window.dart';
import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/profile_picture_window.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataSettings {
  static const String socialFeatures = "social.enable";

  static void registerSettings(SettingController controller) {
    controller.settings[socialFeatures] = Setting<bool>(socialFeatures, false);
  }
}

class DataSettingsPage extends StatelessWidget {
  const DataSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatusController>();
    return SettingsPageBase(
      label: "data",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Social features
          if (Get.find<SettingController>().settings[DataSettings.socialFeatures]!.getValue())
            Padding(
              padding: const EdgeInsets.only(bottom: sectionSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text("settings.data.social".tr, style: Get.theme.textTheme.labelLarge),
                      horizontalSpacing(defaultSpacing),
                      Container(
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.error.withAlpha(25),
                          borderRadius: BorderRadius.circular(defaultSpacing),
                        ),
                        padding: const EdgeInsets.all(elementSpacing),
                        child: Row(
                          children: [
                            Icon(Icons.science, color: Get.theme.colorScheme.error),
                            horizontalSpacing(elementSpacing),
                            Text(
                              "settings.experimental".tr,
                              style: Get.theme.textTheme.bodyMedium!.copyWith(color: Get.theme.colorScheme.error),
                            ),
                            horizontalSpacing(elementSpacing)
                          ],
                        ),
                      )
                    ],
                  ),
                  verticalSpacing(defaultSpacing),
                  Text("settings.data.social.text".tr, style: Get.theme.textTheme.bodyMedium),
                  verticalSpacing(defaultSpacing),
                  const BoolSettingSmall(settingName: DataSettings.socialFeatures),
                ],
              ),
            ),

          //* Profile picture
          Text("settings.data.profile_picture".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(sectionSpacing),
            ),
            padding: const EdgeInsets.all(sectionSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("settings.data.profile_picture.requirements".tr, style: Get.theme.textTheme.bodyMedium),
                      verticalSpacing(defaultSpacing),
                      Row(
                        children: [
                          FJElevatedButton(
                            smallCorners: true,
                            onTap: () async {
                              final result = await openFile();
                              if (result == null) {
                                return;
                              }
                              final size = await result.length();
                              if (size > 10 * 1000 * 1000) {
                                showErrorPopup("error".tr, "settings.data.profile_picture.requirements".tr);
                                return;
                              }

                              final fileType = result.path.split(".").last;
                              if (!["jpeg", "jpg", "png"].contains(fileType)) {
                                showErrorPopup("error".tr, "settings.data.profile_picture.requirements".tr);
                                return;
                              }

                              unawaited(showModal(ProfilePictureWindow(file: result)));
                            },
                            child: Text("change".tr, style: Get.theme.textTheme.labelMedium),
                          ),
                          horizontalSpacing(defaultSpacing),
                          IconButton(
                            tooltip: "settings.data.profile_picture.remove".tr,
                            onPressed: () => showConfirmPopup(
                              ConfirmWindow(
                                title: "settings.data.profile_picture.remove".tr,
                                text: "settings.data.profile_picture.remove.confirm".tr,
                                onConfirm: () async {
                                  // Tell the server to remove the picture
                                  final valid = await ProfileHelper.deleteProfilePicture();
                                  if (!valid) {
                                    return;
                                  }
                                },
                                onDecline: () => {},
                              ),
                            ),
                            icon: Icon(Icons.delete, color: Get.theme.colorScheme.onPrimary),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                UserAvatar(
                  id: StatusController.ownAddress,
                  size: 100,
                )
              ],
            ),
          ),
          verticalSpacing(sectionSpacing),

          //* Name settings
          Text("settings.data.account".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          //* Key requests
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
                      Text("settings.data.key_requests".tr, style: Get.theme.textTheme.labelMedium),
                      verticalSpacing(elementSpacing),
                      Text("settings.data.key_requests.description".tr, style: Get.theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                horizontalSpacing(defaultSpacing),
                FJElevatedButton(
                  smallCorners: true,
                  onTap: () => showModal(const KeyRequestsWindow()),
                  child: Text("view".tr, style: Get.theme.textTheme.labelMedium),
                ),
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),

          //* Display name
          Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(sectionSpacing),
            ),
            padding: const EdgeInsets.all(sectionSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("display_name".tr, style: Get.theme.textTheme.labelMedium),
                    verticalSpacing(elementSpacing),
                    Obx(
                      () => Text(
                        controller.displayName.value.toLowerCase() == controller.name.value.toLowerCase()
                            ? List.generate(controller.name.value.length, (index) => "*").join("")
                            : controller.displayName.value,
                        style: Get.theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                horizontalSpacing(defaultSpacing),
                FJElevatedButton(
                  smallCorners: true,
                  onTap: () => showModal(const ChangeDisplayNameWindow()),
                  child: Text("change".tr, style: Get.theme.textTheme.labelMedium),
                ),
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),

          //* Username
          Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(sectionSpacing),
            ),
            padding: const EdgeInsets.all(sectionSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("username".tr, style: Get.theme.textTheme.labelMedium),
                    verticalSpacing(elementSpacing),
                    Text(
                      List.generate(controller.name.value.length, (index) => "*").join(""),
                      style: Get.theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                horizontalSpacing(defaultSpacing),
                FJElevatedButton(
                  smallCorners: true,
                  onTap: () => showModal(const ChangeNameWindow()),
                  child: Text("change".tr, style: Get.theme.textTheme.labelMedium),
                ),
              ],
            ),
          ),
          verticalSpacing(sectionSpacing),

          /*
          / Email
          Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primaryContainer,
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
                      Text("email".tr, style: Get.theme.textTheme.labelMedium),
                      verticalSpacing(elementSpacing),
                      Text("settings.data.email.description".tr, style: Get.theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                horizontalSpacing(defaultSpacing),
                FJElevatedButton(
                  smallCorners: true,
                  onTap: () => {},
                  child: Text("change".tr, style: Get.theme.textTheme.labelMedium),
                ),
              ],
            ),
          ),
          verticalSpacing(sectionSpacing), */

          //* Log out
          Text("settings.data.log_out".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          Text("settings.data.log_out.description".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),

          //* Danger zone actions
          FJElevatedButton(
            smallCorners: true,
            onTap: () {
              showModal(const LogOutWindow());
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, color: Get.theme.colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Text("log_out".tr, style: Get.theme.textTheme.labelMedium),
              ],
            ),
          ),

          /*
          verticalSpacing(defaultSpacing),
          FJElevatedButton(
            smallCorners: true,
            onTap: () => {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, color: Get.theme.colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Text("settings.data.log_out.button".tr, style: Get.theme.textTheme.labelMedium),
              ],
            ),
          ),*/
          verticalSpacing(sectionSpacing),

          //* Danger zone
          Text("settings.data.danger_zone".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          Text("settings.data.danger_zone.description".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),

          //* Danger zone actions
          FJElevatedButton(
            smallCorners: true,
            onTap: () {
              showConfirmPopup(ConfirmWindow(
                title: "settings.data.danger_zone.delete_account".tr,
                text: "settings.data.danger_zone.delete_account.confirm".tr,
                onConfirm: () => {},
                onDecline: () => {},
              ));
            },
            color: Get.theme.colorScheme.errorContainer,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete, color: Get.theme.colorScheme.error),
                horizontalSpacing(defaultSpacing),
                Text("settings.data.danger_zone.delete_account".tr, style: Get.theme.textTheme.labelMedium),
              ],
            ),
          ),

          verticalSpacing(sectionSpacing),

          //* Permissions (debug)
          Text("settings.data.permissions".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          Text("settings.data.permissions.description".tr, style: Get.theme.textTheme.bodyMedium),
          Text(StatusController.permissions.join(", "), style: Get.theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
