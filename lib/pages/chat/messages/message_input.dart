import 'package:chat_interface/controller/account/writing_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/messages/writing_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../theme/components/icon_button.dart';
import '../../../util/vertical_spacing.dart';

class MessageInput extends StatefulWidget {

  const MessageInput({super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {

  final TextEditingController _message = TextEditingController();
  final loading = false.obs;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MessageController controller = Get.find();
    ThemeData theme = Theme.of(context);

    /* TODO: Reimplement typing indicator
    _message.addListener(() {
      if(_message.text.isNotEmpty) {
        startTyping();
      } else {
        stopTyping();
      }
    });
    */

    Get.find<MessageController>().selectedConversation.listen((conversation) {
      _message.clear();
    });

    return Padding(
      padding: const EdgeInsets.only(
        right: defaultSpacing,
        left: defaultSpacing,
        bottom: defaultSpacing
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        
        children: [
      
          //* Writing status
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(() => WritingStatusNotifier(writers: Get.find<WritingController>().writing[controller.selectedConversation.value.id] ?? []))
          ),
          
          verticalSpacing(defaultSpacing * 0.5),

          //* Input
          Material(
            color: theme.colorScheme.onBackground,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(defaultSpacing * 1.5),
              bottomLeft: Radius.circular(defaultSpacing * 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultSpacing,
                vertical: elementSpacing ,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => {},
                    icon: const Icon(Icons.add),
                    color: theme.colorScheme.primary,
                    tooltip: "soon",
                  ),
                  horizontalSpacing(defaultSpacing),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'chat.message'.tr,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1000),
                      ],
                      style: theme.textTheme.labelLarge,
                      controller: _message,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  horizontalSpacing(defaultSpacing),
                  LoadingIconButton(
                    onTap: () =>
                      sendTextMessage(loading, controller.selectedConversation.value.id, _message.text, "", () {
                        _message.clear();
                        loading.value = false;
                      })
                    ,
                    icon: Icons.send,
                    color: theme.colorScheme.primary,
                    loading: loading,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}