import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/chat/components/message/message_list.dart';
import 'package:chat_interface/pages/settings/appearance/chat_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/chat/messages/message_input.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class MessageFeed extends StatefulWidget {
  final double? overwritePadding;
  final bool rectInput;

  const MessageFeed({super.key, this.overwritePadding, this.rectInput = false});

  @override
  State<MessageFeed> createState() => _MessageFeedState();
}

class _MessageFeedState extends State<MessageFeed> {
  final TextEditingController _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((ctx) {
      final provider = (SidebarController.currentOpenTab.value as ConversationSidebarTab).provider;
      if (provider.conversation.error.value != null) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("conversation.error".tr, style: Get.textTheme.titleMedium),
                verticalSpacing(defaultSpacing),
                Text(provider.conversation.error.value!, style: Get.textTheme.bodyMedium, textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }

      return Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  // Message list
                  Expanded(
                    child: Stack(
                      children: [
                        // Messages
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (SettingController.settings[ChatSettings.chatTheme]!.value.value ?? 1) == 0 ? double.infinity : 1200,
                            ),
                            child: Watch((ctx) {
                              if (!MessageController.loaded.value) {
                                return const SizedBox();
                              }

                              return MessageList(
                                key: ValueKey(provider.conversation.id),
                                provider: provider,
                                overwritePadding: isMobileMode() ? defaultSpacing : sectionSpacing,
                              );
                            }),
                          ),
                        ),

                        // Animated loading indicator
                        Align(
                          alignment: Alignment.topCenter,
                          child: Watch(key: ValueKey(provider.conversation.id), (ctx) {
                            return Visibility(
                              visible: provider.newMessagesLoading.value,
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
                                          child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary, strokeWidth: 3),
                                        ),
                                        horizontalSpacing(defaultSpacing),
                                        Text("loading".tr, style: Get.textTheme.labelMedium),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  //* Message input
                  SelectionContainer.disabled(
                    child:
                        provider.conversation.borked
                            ? const SizedBox.shrink()
                            : MessageInput(rectangle: widget.rectInput, draft: provider.conversation.id.encode(), provider: provider),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
