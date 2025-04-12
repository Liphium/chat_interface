import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_conversations.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_profile.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/pages/status/error/offline_hider.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/space_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/upgrade_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_core.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final _query = signal("");
  final GlobalKey _addConvKey = GlobalKey(), _addSpaceKey = GlobalKey();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Get.theme.colorScheme.onInverseSurface),

      //* Sidebar content
      child: DevicePadding(
        top: true,
        right: true,
        left: true,
        padding: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding for the sidebar to make sure the error doesn't look weird
            verticalSpacing(defaultSpacing),

            // Show error from the connection
            SafeArea(
              top: false,
              bottom: false,
              child: AnimatedErrorContainer(
                padding: const EdgeInsets.only(bottom: defaultSpacing, right: defaultSpacing, left: defaultSpacing),
                message: ConnectionController.error,
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
              child: SizedBox(
                height: 48,
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
                                    _query.value = value;
                                  },
                                  cursorColor: Get.theme.colorScheme.onPrimary,
                                ),
                              ),

                              // Put all of the buttons into a row so we can disable them when offline
                              OfflineHider(
                                axis: Axis.horizontal,
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    horizontalSpacing(defaultSpacing * 0.5),
                                    Visibility(
                                      visible: areSpacesSupported,
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

                                        // Open conversation add window
                                        showModal(
                                          ConversationAddWindow(
                                            position: ContextMenuData(
                                              box.localToGlobal(box.size.bottomLeft(const Offset(0, elementSpacing))),
                                              true,
                                              true,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.chat_bubble, color: Get.theme.colorScheme.onPrimary),
                                    ),
                                  ],
                                ),
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

            // Conversation list and the profile
            Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: defaultSpacing), child: SidebarConversationList(query: _query)),
              ),
            ),
            if (!isMobileMode()) const SidebarProfile(),
          ],
        ),
      ),
    );
  }
}
