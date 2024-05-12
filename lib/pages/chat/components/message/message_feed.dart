import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_members.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_renderer.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/appearance/chat_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/pages/spaces/call_rectangle.dart';
import 'package:chat_interface/pages/chat/components/conversations/message_bar.dart';
import 'package:chat_interface/pages/chat/messages/message_input.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'message_actions.dart';

class MessageFeed extends StatefulWidget {
  final Conversation? conversation;

  const MessageFeed({super.key, required this.conversation});

  @override
  State<MessageFeed> createState() => _MessageFeedState();
}

class _MessageFeedState extends State<MessageFeed> {
  final TextEditingController _message = TextEditingController();
  final loading = false.obs;
  final _scrollController = ScrollController();

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
    if (widget.conversation == null || widget.conversation?.id == "0") {
      if (Get.find<SpacesController>().inSpace.value) {
        return const CallRectangle();
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('app.title'.tr, style: Theme.of(context).textTheme.headlineMedium),
          verticalSpacing(sectionSpacing),
          Text('app.welcome'.tr, style: Theme.of(context).textTheme.bodyLarge),
          verticalSpacing(elementSpacing),
          Text('app.build'.trParams({"build": "Alpha"}), style: Theme.of(context).textTheme.bodyLarge),
        ],
      );
    }

    MessageController controller = Get.find();
    SettingController settingController = Get.find();

    return Column(
      children: [
        //* Header
        MessageBar(conversation: controller.selectedConversation.value),

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

                                return ListView.builder(
                                  itemCount: controller.messages.length + 1,
                                  reverse: true,
                                  controller: _scrollController,
                                  addAutomaticKeepAlives: false,
                                  addRepaintBoundaries: false,
                                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                  itemBuilder: (context, index) {
                                    return BubblesRenderer(index: index);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      //* Message input
                      SelectionContainer.disabled(
                        child: widget.conversation!.borked ? const SizedBox.shrink() : const MessageInput(),
                      )
                    ],
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible: controller.selectedConversation.value.isGroup && settingController.settings[AppSettings.showGroupMembers]!.value.value,
                  child: Container(
                    color: Get.theme.colorScheme.onBackground,
                    width: 300,
                    child: ConversationMembers(
                      conversation: widget.conversation!,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
