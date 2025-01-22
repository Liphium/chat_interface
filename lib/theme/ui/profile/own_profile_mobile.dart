import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/account/data_settings.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/forms/lph_action_fields.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/profile/developer_window.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OwnProfileMobile extends StatefulWidget {
  const OwnProfileMobile({super.key});

  @override
  State<OwnProfileMobile> createState() => _OwnProfileMobileState();
}

class _OwnProfileMobileState extends State<OwnProfileMobile> {
  //* Edit state for buttons
  final edit = false.obs;

  final TextEditingController _status = TextEditingController();
  final statusMessage = "".obs;
  final FocusNode _statusFocus = FocusNode();

  // Developer things
  final testLoading = false.obs;
  final _clicks = 0.obs;

  @override
  void dispose() {
    _status.dispose();
    _statusFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StatusController controller = Get.find();
    ThemeData theme = Theme.of(context);

    _status.text = controller.status.value;
    statusMessage.value = controller.status.value;

    return DevicePadding(
      top: true,
      right: true,
      left: true,
      padding: EdgeInsets.all(defaultSpacing * 1.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About your profile",
            style: Get.textTheme.titleMedium,
          ),
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
                          children: [
                            UserAvatar(
                              id: StatusController.ownAddress,
                              size: 60,
                            ),
                          ],
                        ),
                      ),
                      horizontalSpacing(sectionSpacing),
                      Expanded(
                        child: Text(
                          controller.name.value,
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
                          _clicks.value++;
                          if (_clicks.value > 7) {
                            showModal(const DeveloperWindow());
                          }
                          Clipboard.setData(ClipboardData(text: controller.name.value));
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
          Obx(() {
            if (controller.ownContainer.value != null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: elementSpacing),
                child: ProfileButton(
                  icon: Icons.stop,
                  label: 'profile.stop_sharing'.tr,
                  onTap: () => controller.stopSharing(),
                  loading: false.obs,
                ),
              );
            }

            if (SpaceController.connected.value) {
              return Padding(
                padding: const EdgeInsets.only(bottom: elementSpacing),
                child: ProfileButton(
                  icon: Icons.start,
                  label: 'profile.start_sharing'.tr,
                  onTap: () => controller.share(SpaceController.getContainer()),
                  loading: false.obs,
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
            child: GetX<StatusController>(builder: (statusController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(4, (index) {
                  // Get details
                  Color color = getStatusColor(theme, index);
                  IconData icon = getStatusIcon(index);
                  final bool selected = statusController.type.value == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: defaultSpacing),
                    child: Material(
                      color: selected ? theme.colorScheme.primary : theme.colorScheme.inverseSurface,
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        onTap: () {
                          controller.setStatus(type: index, success: () => Get.back());
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
                                  color: selected ? theme.colorScheme.onSurface : theme.colorScheme.surface,
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

          //* Status message
          if (!isMobileMode())
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //* Profile id
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      edit.value = true;
                      _statusFocus.requestFocus();
                    },
                    child: Obx(
                      () => Visibility(
                        visible: edit.value,
                        replacement: Text(
                          controller.status.value == "" ? 'status.message.add'.tr : controller.status.value,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textHeightBehavior: noTextHeight,
                        ),
                        child: TextField(
                          focusNode: _statusFocus,
                          onChanged: (value) => statusMessage.value = value,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: theme.textTheme.bodyMedium!,
                            hintText: 'status.message'.tr,
                          ),
                          style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurface),

                          //* Save status
                          onEditingComplete: () {
                            if (_status.text == "") _status.text = "";
                            controller.setStatus(message: _status.text);
                            edit.value = false;
                          },

                          inputFormatters: [
                            LengthLimitingTextInputFormatter(70),
                          ],
                          controller: _status,
                        ),
                      ),
                    ),
                  ),
                ),

                //* Close button
                if (!isMobileMode())
                  Obx(
                    () => LoadingIconButton(
                      loading: controller.statusLoading,
                      onTap: () {
                        if (controller.status.value == "" && !edit.value) {
                          edit.value = true;
                          _status.text = "";
                          _statusFocus.requestFocus();
                          return;
                        }

                        if (!edit.value) {
                          controller.setStatus(message: "");
                          _status.text = "";
                          return;
                        }

                        edit.value = false;
                        _statusFocus.unfocus();
                        controller.setStatus(message: _status.text);
                      },
                      icon: statusMessage.value == ""
                          ? Icons.add
                          : edit.value
                              ? Icons.done
                              : Icons.close,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
              ],
            ),
        ],
      ),
    );
  }
}
