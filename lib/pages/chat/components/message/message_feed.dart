import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_members.dart';
import 'package:chat_interface/pages/chat/components/conversations/message_bar_mobile.dart';
import 'package:chat_interface/pages/chat/components/message/message_list.dart';
import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:chat_interface/pages/settings/appearance/chat_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/message_bar.dart';
import 'package:chat_interface/pages/chat/messages/message_input.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

part 'message_actions.dart';

class MessageFeed extends StatefulWidget {
  const MessageFeed({super.key});

  @override
  State<MessageFeed> createState() => _MessageFeedState();
}

class _MessageFeedState extends State<MessageFeed> {
  final TextEditingController _message = TextEditingController();
  final loading = false.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MessageController controller = Get.find();
    SettingController settingController = Get.find();

    return Obx(() {
      if (controller.currentProvider.value!.conversation.error.value != null) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "conversation.error".tr,
                  style: Get.textTheme.titleMedium,
                ),
                verticalSpacing(defaultSpacing),
                Text(
                  controller.currentProvider.value!.conversation.error.value!,
                  style: Get.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          //* Header
          if (isMobileMode())
            MobileMessageBar(conversation: controller.currentProvider.value!.conversation)
          else
            MessageBar(conversation: controller.currentProvider.value!.conversation),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: [
                        //* Message list
                        Expanded(
                          child: Stack(
                            children: [
                              //* Animated loading indicator
                              Align(
                                alignment: Alignment.topCenter,
                                child: Obx(
                                  () => Animate(
                                    effects: [
                                      FadeEffect(
                                        curve: Curves.ease,
                                        duration: 250.ms,
                                      ),
                                    ],
                                    target: controller.currentProvider.value!.newMessagesLoading.value ? 1 : 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(defaultSpacing),
                                      child: Material(
                                        elevation: 3.0,
                                        color: Get.theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(defaultSpacing),
                                        child: Padding(
                                          padding: const EdgeInsets.all(defaultSpacing),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: Get.textTheme.labelMedium!.fontSize! * 1.5,
                                                height: Get.textTheme.labelMedium!.fontSize! * 1.5,
                                                child: CircularProgressIndicator(
                                                  color: Get.theme.colorScheme.onPrimary,
                                                  strokeWidth: 3,
                                                ),
                                              ),
                                              horizontalSpacing(defaultSpacing),
                                              Text("loading".tr, style: Get.textTheme.labelMedium),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //* Messages
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: (ChatSettings.chatThemeSetting.value.value ?? 1) == 0 ? double.infinity : 1200,
                                  ),
                                  child: Obx(
                                    () {
                                      if (!controller.loaded.value) {
                                        return const SizedBox();
                                      }

                                      return MessageList(
                                        key: ValueKey(controller.currentProvider.value!.conversation.id),
                                        provider: controller.currentProvider.value!,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        //* Message input
                        SelectionContainer.disabled(
                          child: controller.currentProvider.value!.conversation.borked
                              ? const SizedBox.shrink()
                              : MessageInput(
                                  conversation: controller.currentProvider.value!.conversation,
                                ),
                        )
                      ],
                    ),
                  ),
                ),
                Obx(() {
                  final visible = settingController.settings[AppSettings.showGroupMembers]!.value.value;
                  return Visibility(
                    visible: controller.currentProvider.value!.conversation.isGroup && visible,
                    child: Container(
                      color: Get.theme.colorScheme.onInverseSurface,
                      width: 300,
                      child: ConversationMembers(
                        conversation: controller.currentProvider.value!.conversation,
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        ],
      );
    });
  }
}
