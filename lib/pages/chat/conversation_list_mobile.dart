import 'package:chat_interface/pages/chat/sidebar/sidebar_conversations.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationListMobile extends StatefulWidget {
  const ConversationListMobile({super.key});

  @override
  State<ConversationListMobile> createState() => _SidebarState();
}

class _SidebarState extends State<ConversationListMobile> {
  @override
  Widget build(BuildContext context) {
    //* Sidebar
    return Container(
      decoration: BoxDecoration(color: Get.theme.colorScheme.onInverseSurface),

      //* Sidebar content
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A header to just cover up some space for now
              Container(
                color: Get.theme.colorScheme.primaryContainer,
                child: DevicePadding(
                  top: true,
                  padding: const EdgeInsets.all(0),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultSpacing * 1.5),
                    child: Row(
                      children: [
                        SizedBox(height: 32, child: Image.asset("assets/tray/icon_linux.png")),
                        horizontalSpacing(defaultSpacing * 1.5),
                        Text("Liphium", style: Get.textTheme.labelLarge),
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
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: defaultSpacing), child: SidebarConversationList()),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing * 1.5),
              child: LoadingIconButton(
                onTap: () => showModal(ConversationAddWindow(position: ContextMenuData.fromPosition(Offset.zero))),
                icon: Icons.group_add,
                iconSize: 28,
                extra: 24,
                background: true,
                backgroundColor: Get.theme.colorScheme.primary,
                color: Get.theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
