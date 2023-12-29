
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/theme/ui/dialogs/message_info_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageOptionsWindow extends StatefulWidget {

  final ContextMenuData data;
  final bool self;
  final Message message;
  
  const MessageOptionsWindow({super.key, required this.data, required this.self, required this.message});

  @override
  State<MessageOptionsWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<MessageOptionsWindow> {

  final messageDeletionLoading = false.obs;

  @override
  Widget build(BuildContext context) {

    return SlidingWindowBase(
      lessPadding: true,
      position: widget.data,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                
          ProfileButton(
            icon: Icons.info, 
            label: "message.info".tr, 
            onTap: () {
              Get.back();
              Get.dialog(MessageInfoWindow(message: widget.message));
            }, 
            loading: false.obs,
          ),
          if(widget.message.type == MessageType.text)
            Padding(
              padding: const EdgeInsets.only(top: elementSpacing),
              child: ProfileButton(
                icon: Icons.copy, 
                label: "message.copy".tr, 
                onTap: () => {}, 
                loading: false.obs,
              ),
            ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.person, 
            label: "message.profile".tr, 
            onTap: () => {}, 
            loading: false.obs,
          ),
          if(widget.self)
            Padding(
              padding: const EdgeInsets.only(top: defaultSpacing),
              child: ProfileButton(
                color: Get.theme.colorScheme.onError,
                iconColor: Get.theme.colorScheme.error,
                icon: Icons.delete, 
                label: "message.delete".tr, 
                onTap: () async {

                  // Set and check loading state
                  if(messageDeletionLoading.value) return;
                  messageDeletionLoading.value = true;

                  // Delete message
                  final result = await widget.message.delete();
                 messageDeletionLoading.value = false;
                  if(result != null) {
                    showErrorPopup("error", result);
                    return;
                  }

                  Get.back();
                }, 
                loading: messageDeletionLoading,
              ),
            ),
        ],
      ),
    );
  }
}