
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageOptionsWindow extends StatefulWidget {

  final ContextMenuData data;
  
  const MessageOptionsWindow({super.key, required this.data});

  @override
  State<MessageOptionsWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<MessageOptionsWindow> {

  @override
  Widget build(BuildContext context) {

    return SlidingWindowBase(
      position: widget.data,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                
          ProfileButton(
            icon: Icons.delete, 
            label: "message.delete".tr, 
            onTap: () => {}, 
            loading: false.obs,
          ),
          verticalSpacing(defaultSpacing),
          ProfileButton(
            icon: Icons.delete, 
            label: "message.delete".tr, 
            onTap: () => {}, 
            loading: false.obs,
          ),
        ],
      ),
    );
  }
}