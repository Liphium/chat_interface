import 'package:chat_interface/connection/impl/messages/typing_listener.dart';
import 'package:chat_interface/controller/chat/message_controller.dart';
import 'package:chat_interface/controller/chat/writing_controller.dart';
import 'package:chat_interface/pages/chat/components/message_feed.dart';
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

    _message.addListener(() {
      if(_message.text.isNotEmpty) {
        startTyping();
      } else {
        stopTyping();
      }
    });

    Get.find<MessageController>().selectedConversation.listen((conversation) {
      _message.clear();
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 2, vertical: defaultSpacing),
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
            elevation: 10,
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultSpacing,
                vertical: defaultSpacing * 0.1,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => {},
                    icon: const Icon(Icons.add),
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
                      controller: _message,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  horizontalSpacing(defaultSpacing),
                  LoadingIconButton(
                    onTap: () => sendMessage(loading, controller.selectedConversation.value.id, _message.text, () {
                      _message.clear();
                      loading.value = false;
                    }),
                    icon: Icons.send,
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