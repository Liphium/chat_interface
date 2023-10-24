import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/message_space_renderer.dart';
import 'package:chat_interface/pages/settings/settings_page.dart';
import 'package:chat_interface/theme/components/duration_renderer.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: Column(
                children: [

                  //* Spaces status
                  GetX<SpacesController>(
                    builder: (controller) {
                      if(!controller.inSpace.value) {
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
                                padding: const EdgeInsets.all(defaultSpacing),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(controller.title.value, style: Get.theme.textTheme.labelMedium),
                                        verticalSpacing(elementSpacing),
                                        renderMiniAvatars(1)
                                      ],
                                    ),
                                    horizontalSpacing(defaultSpacing),
                                    DurationRenderer(controller.start.value, style: theme.textTheme.bodyLarge)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          verticalSpacing(defaultSpacing),
                        ],
                      );
                    }
                  ),

                  //* Actual profile
                  Material(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    color: theme.colorScheme.primaryContainer,
                    child: InkWell(
                      onTap: () => Get.dialog(const OwnProfile(position: Offset(defaultSpacing, 60))),
                      splashColor: theme.hoverColor.withAlpha(10),
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      hoverColor: theme.colorScheme.background,
                      splashFactory: NoSplash.splashFactory,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: elementSpacing, vertical: elementSpacing),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    size: 35,
                                  ),
                                  horizontalSpacing(defaultSpacing * 0.75),
                                  Expanded(
                                    child: Obx(() =>
                                      Visibility(
                                        visible: !controller.statusLoading.value,
                                        replacement: const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(defaultSpacing),
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(strokeWidth: 4.0,)
                                            )
                                          )
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                      
                                            //* Profile name and status type
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Obx(() =>
                                                    Text(controller.name.value, style: theme.textTheme.titleMedium, 
                                                      textHeightBehavior: noTextHeight,
                                                    ),
                                                  )
                                                ),
                                                horizontalSpacing(defaultSpacing),
                                                Obx(() =>
                                                  StatusRenderer(status: controller.type.value)
                                                )
                                              ],
                                            ),
          
                                            //* Status message
                                            Obx(() =>
                                              Visibility(
                                                visible: controller.status.value != "-",
                                                child: Column(
                                                  children: [
                                                    verticalSpacing(defaultSpacing * 0.25),
                                              
                                                    //* Status message
                                                    Text(controller.status.value, style: theme.textTheme.bodySmall, 
                                                      textHeightBehavior: noTextHeight, overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ]
                                                ) 
                                              )
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ),
                            horizontalSpacing(defaultSpacing),
                            Row(
                              children: [
                                horizontalSpacing(defaultSpacing * 0.5),
                                IconButton(
                                  onPressed: () => Get.to(const SettingsPage(), duration: 300.ms, transition: Transition.fade, curve: Curves.easeInOut),
                                  icon: const Icon(Icons.settings, color: Colors.white),
                                ),
                              ],
                            )
                          ],
                        )
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}