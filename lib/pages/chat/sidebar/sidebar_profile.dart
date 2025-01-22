import 'dart:math';

import 'package:chat_interface/controller/account/friends/requests_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/services/spaces/space_container.dart';
import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/spaces/widgets/space_info_window.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/own_profile.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SidebarProfile extends StatefulWidget {
  const SidebarProfile({super.key});

  @override
  State<SidebarProfile> createState() => _SidebarProfileState();
}

class _SidebarProfileState extends State<SidebarProfile> {
  final GlobalKey _profileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final statusController = Get.find<StatusController>();
    ThemeData theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primaryContainer,
      child: SafeArea(
        bottom: true,
        top: false,
        right: true,
        left: true,
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: Column(
                children: [
                  Watch((context) {
                    if (!SpaceController.connected.value) {
                      // Render an embed letting the user know he's in a call on another device
                      return Obx(() {
                        if (statusController.ownContainer.value != null && statusController.ownContainer.value is SpaceConnectionContainer) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: elementSpacing, horizontal: defaultSpacing),
                            child: Row(
                              children: [
                                Icon(Icons.public, color: Get.theme.colorScheme.onPrimary),
                                horizontalSpacing(defaultSpacing),
                                Text("spaces.sharing_other_device".tr, style: Get.theme.textTheme.bodyMedium),
                                const Spacer(),
                                LoadingIconButton(
                                  onTap: () => SpaceController.join(statusController.ownContainer.value! as SpaceConnectionContainer),
                                  icon: Icons.login,
                                  extra: defaultSpacing,
                                  iconSize: 25,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox();
                      });
                    }

                    return Obx(() {
                      final shown = Get.find<MessageController>().currentProvider.value == null;

                      return Column(
                        children: [
                          Material(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            color: shown ? theme.colorScheme.inverseSurface : theme.colorScheme.primaryContainer,
                            child: InkWell(
                              onTap: () {
                                final controller = Get.find<MessageController>();
                                controller.unselectConversation();
                                controller.currentOpenType.value = OpenTabType.space;
                              },
                              splashColor: theme.hoverColor,
                              hoverColor: shown ? theme.colorScheme.inverseSurface : theme.colorScheme.inverseSurface,
                              borderRadius: BorderRadius.circular(defaultSpacing),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: elementSpacing, horizontal: defaultSpacing),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.public, color: Get.theme.colorScheme.onPrimary),
                                      ],
                                    ),
                                    horizontalSpacing(defaultSpacing),
                                    const Spacer(),
                                    LoadingIconButton(
                                      padding: 0,
                                      extra: 10,
                                      iconSize: 25,
                                      onTap: () => Get.dialog(const SpaceInfoWindow()),
                                      icon: Icons.info,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          verticalSpacing(defaultSpacing),
                        ],
                      );
                    });
                  }),

                  //* Actual profile
                  Material(
                    key: _profileKey,
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    color: theme.colorScheme.primaryContainer,
                    child: InkWell(
                      onTap: () => showModal(OwnProfile(position: ContextMenuData.fromKey(_profileKey, above: true))),
                      splashColor: theme.hoverColor.withAlpha(10),
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      hoverColor: theme.colorScheme.inverseSurface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: elementSpacing, vertical: elementSpacing),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() {
                              // Check if the thing is loading
                              if (Get.find<ConnectionController>().loading.value) {
                                return Row(
                                  children: [
                                    horizontalSpacing(defaultSpacing),
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        color: Get.theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                    horizontalSpacing(defaultSpacing),
                                    Text("loading".tr, style: Get.textTheme.labelLarge),
                                  ],
                                );
                              }

                              // Check if the thing is connected
                              if (!Get.find<ConnectionController>().connected.value) {
                                return Row(
                                  children: [
                                    horizontalSpacing(defaultSpacing),
                                    Icon(
                                      Icons.cloud_off,
                                      color: Get.theme.colorScheme.onPrimary,
                                    ),
                                    horizontalSpacing(defaultSpacing),
                                    Text("offline".tr, style: Get.textTheme.labelLarge),
                                  ],
                                );
                              }

                              return Expanded(
                                child: Row(
                                  children: [
                                    UserAvatar(id: StatusController.ownAddress, size: 40),
                                    horizontalSpacing(defaultSpacing),
                                    Expanded(
                                      child: Obx(
                                        () => Visibility(
                                          visible: !statusController.statusLoading.value,
                                          replacement: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(defaultSpacing),
                                              child: SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3.0,
                                                  color: Get.theme.colorScheme.onPrimary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              //* Profile name and status type
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Obx(
                                                      () => Text(
                                                        statusController.displayName.value,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: theme.textTheme.titleMedium,
                                                        textHeightBehavior: noTextHeight,
                                                      ),
                                                    ),
                                                  ),
                                                  horizontalSpacing(defaultSpacing),
                                                  Obx(
                                                    () => StatusRenderer(status: statusController.type.value, text: false),
                                                  )
                                                ],
                                              ),

                                              //* Status message
                                              Obx(
                                                () => Visibility(
                                                  visible: statusController.status.value != "",
                                                  child: Column(
                                                    children: [
                                                      verticalSpacing(defaultSpacing * 0.25),

                                                      //* Status message
                                                      Text(
                                                        statusController.status.value,
                                                        style: theme.textTheme.bodySmall,
                                                        textHeightBehavior: noTextHeight,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                            horizontalSpacing(defaultSpacing),
                            Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Stack(
                                    children: [
                                      IconButton(
                                        onPressed: () => showModal(const FriendsPage()),
                                        icon: const Icon(Icons.group, color: Colors.white),
                                      ),
                                      Obx(() {
                                        final controller = Get.find<RequestController>();
                                        if (controller.requests.isEmpty) {
                                          return const SizedBox();
                                        }
                                        final amount = controller.requests.length;

                                        return Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Get.theme.colorScheme.error,
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                            padding: const EdgeInsets.only(bottom: elementSpacing),
                                            child: Center(
                                              child: Text(
                                                min(amount, 9).toString(),
                                                style: Get.textTheme.labelSmall!.copyWith(fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                horizontalSpacing(defaultSpacing * 0.5),
                                IconButton(
                                  onPressed: () => SettingController.openSettingsPage(),
                                  icon: const Icon(Icons.settings, color: Colors.white),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
