import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_conversations.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_profile.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/space_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/upgrade_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final query = "".obs;
  final GlobalKey _addConvKey = GlobalKey(), _addSpaceKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    //* Sidebar
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onInverseSurface,
      ),

      //* Sidebar content
      child: LayoutBuilder(builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.only(top: Get.mediaQuery.padding.top != 0 && GetPlatform.isMobile ? 0 : defaultSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show error from the connection
              SafeArea(
                bottom: false,
                child: AnimatedErrorContainer(
                  padding: const EdgeInsets.only(
                    bottom: defaultSpacing,
                    right: defaultSpacing,
                    left: defaultSpacing,
                  ),
                  message: Get.find<ConnectionController>().error,
                ),
              ),

              //* Search field
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Material(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            color: Get.theme.colorScheme.primary,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
                              child: Row(
                                children: [
                                  horizontalSpacing(defaultSpacing),
                                  Icon(Icons.search, color: Get.theme.colorScheme.onPrimary),
                                  horizontalSpacing(defaultSpacing),
                                  Expanded(
                                    child: TextField(
                                      style: Get.theme.textTheme.labelMedium,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusColor: Get.theme.colorScheme.onPrimary,
                                        iconColor: Get.theme.colorScheme.onPrimary,
                                        fillColor: Get.theme.colorScheme.onPrimary,
                                        hoverColor: Get.theme.colorScheme.onPrimary,
                                        hintText: "conversations.placeholder".tr,
                                        hintStyle: Get.textTheme.bodyMedium,
                                      ),
                                      onChanged: (value) {
                                        query.value = value;
                                      },
                                      cursorColor: Get.theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  horizontalSpacing(defaultSpacing * 0.5),
                                  Visibility(
                                    visible: !GetPlatform.isMobile,
                                    child: IconButton(
                                      key: _addSpaceKey,
                                      onPressed: () {
                                        if (isWeb) {
                                          Get.dialog(UpgradeWindow());
                                          return;
                                        }

                                        //* Open space add window
                                        final RenderBox box = _addSpaceKey.currentContext?.findRenderObject() as RenderBox;
                                        showModal(SpaceAddWindow(position: box.localToGlobal(box.size.bottomLeft(const Offset(0, 5)))));
                                      },
                                      icon: Icon(Icons.rocket_launch, color: Get.theme.colorScheme.onPrimary),
                                    ),
                                  ),
                                  horizontalSpacing(defaultSpacing * 0.5),
                                  IconButton(
                                    key: _addConvKey,
                                    onPressed: () {
                                      final RenderBox box = _addConvKey.currentContext?.findRenderObject() as RenderBox;

                                      //* Open conversation add window
                                      showModal(ConversationAddWindow(
                                        position:
                                            ContextMenuData(box.localToGlobal(box.size.bottomLeft(const Offset(0, elementSpacing))), true, true),
                                      ));
                                    },
                                    icon: Icon(Icons.chat_bubble, color: Get.theme.colorScheme.onPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Conversation list and the profile
              Expanded(
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                    child: SidebarConversationList(query: query),
                  ),
                ),
              ),
              if (!isMobileMode()) const SidebarProfile()
            ],
          ),
        );
      }),
    );
  }
}
