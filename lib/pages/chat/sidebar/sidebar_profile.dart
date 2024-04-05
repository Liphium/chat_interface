import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/publication_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/message_space_renderer.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/pages/settings/settings_page.dart';
import 'package:chat_interface/pages/spaces/widgets/space_info_window.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/profile/own_profile.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SidebarProfile extends StatefulWidget {
  const SidebarProfile({super.key});

  @override
  State<SidebarProfile> createState() => _SidebarProfileState();
}

class _SidebarProfileState extends State<SidebarProfile> {
  @override
  Widget build(BuildContext context) {
    StatusController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(defaultSpacing),
        child: LayoutBuilder(builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Column(
              children: [
                //* Spaces status
                GetX<SpacesController>(builder: (controller) {
                  if (!controller.inSpace.value) {
                    return const SizedBox.shrink();
                  }
                  final shown = Get.find<MessageController>().selectedConversation.value.id == "0";

                  return Column(
                    children: [
                      Material(
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        color: shown ? theme.colorScheme.background : theme.colorScheme.primaryContainer,
                        child: InkWell(
                          onTap: () => Get.find<MessageController>().unselectConversation(),
                          splashColor: theme.hoverColor,
                          hoverColor: shown ? theme.colorScheme.background : theme.colorScheme.background,
                          borderRadius: BorderRadius.circular(defaultSpacing),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: elementSpacing, horizontal: defaultSpacing),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Text(controller.title.value, style: Get.theme.textTheme.labelMedium),
                                    //verticalSpacing(elementSpacing),
                                    Obx(() => renderMiniAvatars(Get.find<SpaceMemberController>().members.length)),
                                  ],
                                ),
                                horizontalSpacing(defaultSpacing),
                                const Spacer(),
                                GetX<PublicationController>(
                                  builder: (controller) {
                                    return LoadingIconButton(
                                      loading: controller.muteLoading,
                                      onTap: () => controller.setMuted(!controller.muted.value),
                                      icon: controller.muted.value ? Icons.mic_off : Icons.mic,
                                      extra: defaultSpacing,
                                      iconSize: 25,
                                      color: theme.colorScheme.onSurface,
                                    );
                                  },
                                ),
                                GetX<PublicationController>(
                                  builder: (controller) {
                                    return LoadingIconButton(
                                      loading: controller.deafenLoading,
                                      onTap: () => controller.setDeafened(!controller.deafened.value),
                                      icon: controller.deafened.value ? Icons.volume_off : Icons.volume_up,
                                      extra: defaultSpacing,
                                      iconSize: 25,
                                      color: theme.colorScheme.onSurface,
                                    );
                                  },
                                ),
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
                }),

                //* Actual profile
                Material(
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  color: theme.colorScheme.primaryContainer,
                  child: InkWell(
                    onTap: () => Get.dialog(const OwnProfile(position: Offset(defaultSpacing, 60))),
                    splashColor: theme.hoverColor.withAlpha(10),
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    hoverColor: theme.colorScheme.background,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: elementSpacing, vertical: elementSpacing),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Row(
                              children: [
                                UserAvatar(id: StatusController.ownAccountId, size: 40),
                                horizontalSpacing(defaultSpacing * 0.75),
                                Expanded(
                                  child: Obx(
                                    () => Visibility(
                                      visible: !controller.statusLoading.value,
                                      replacement: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(defaultSpacing),
                                          child: SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 4.0,
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
                                                    controller.name.value,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.titleMedium,
                                                    textHeightBehavior: noTextHeight,
                                                  ),
                                                ),
                                              ),
                                              horizontalSpacing(defaultSpacing),
                                              Obx(
                                                () => StatusRenderer(status: controller.type.value, text: false),
                                              )
                                            ],
                                          ),

                                          //* Status message
                                          Obx(() => Visibility(
                                              visible: controller.status.value != "-",
                                              child: Column(children: [
                                                verticalSpacing(defaultSpacing * 0.25),

                                                //* Status message
                                                Text(
                                                  controller.status.value,
                                                  style: theme.textTheme.bodySmall,
                                                  textHeightBehavior: noTextHeight,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ])))
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )),
                            horizontalSpacing(defaultSpacing),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Get.dialog(const FriendsPage()),
                                  icon: const Icon(Icons.group, color: Colors.white),
                                ),
                                horizontalSpacing(defaultSpacing * 0.5),
                                IconButton(
                                  onPressed: () => Get.to(const SettingsPage(), duration: 300.ms, transition: Transition.fade, curve: Curves.easeInOut),
                                  icon: const Icon(Icons.settings, color: Colors.white),
                                ),
                              ],
                            )
                          ],
                        )),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
