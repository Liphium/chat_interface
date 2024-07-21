import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_members.dart';
import 'package:chat_interface/pages/chat/components/conversations/message_bar_mobile.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_mobile_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_renderer.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/appearance/chat_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/message_bar.dart';
import 'package:chat_interface/pages/chat/messages/message_input.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

part 'message_actions.dart';

class MessageFeed extends StatefulWidget {
  final Conversation conversation;

  const MessageFeed({super.key, required this.conversation});

  @override
  State<MessageFeed> createState() => _MessageFeedState();
}

class _MessageFeedState extends State<MessageFeed> {
  final TextEditingController _message = TextEditingController();
  final loading = false.obs;
  final _scrollController = AutoScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<MessageController>().newScrollController(_scrollController);
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MessageController controller = Get.find();
    SettingController settingController = Get.find();

    return Column(
      children: [
        //* Header
        if (isMobileMode()) MobileMessageBar(conversation: widget.conversation) else MessageBar(conversation: widget.conversation),

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
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: (ChatSettings.chatThemeSetting.value.value ?? 1) == 0 ? double.infinity : 1200),
                            child: Obx(
                              () {
                                if (!controller.loaded.value) {
                                  return const SizedBox();
                                }

                                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                  controller.checkCurrentScrollHeight();
                                });

                                return ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                  child: ListView.builder(
                                    itemCount: controller.messages.length + 2,
                                    reverse: true,
                                    controller: _scrollController,
                                    addAutomaticKeepAlives: false,
                                    addRepaintBoundaries: false,
                                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                    itemBuilder: (context, index) {
                                      if (isMobileMode()) {
                                        return BubblesMobileRenderer(
                                          index: index,
                                          controller: _scrollController,
                                        );
                                      }
                                      return BubblesRenderer(
                                        index: index,
                                        controller: _scrollController,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      //* Message input
                      SelectionContainer.disabled(
                        child: widget.conversation.borked
                            ? const SizedBox.shrink()
                            : MessageInput(
                                conversation: widget.conversation,
                              ),
                      )
                    ],
                  ),
                ),
              ),
              Obx(() {
                final visible = settingController.settings[AppSettings.showGroupMembers]!.value.value;
                return Visibility(
                  visible: widget.conversation.isGroup && visible,
                  child: Container(
                    color: Get.theme.colorScheme.onInverseSurface,
                    width: 300,
                    child: ConversationMembers(
                      conversation: widget.conversation,
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ],
    );
  }
}
