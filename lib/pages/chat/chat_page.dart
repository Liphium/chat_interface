import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:chat_interface/controller/chat/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/notification_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  @override
  Widget build(BuildContext context) {
    MessageController controller = Get.find();
    NotificationController notificationController = Get.find();

    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 350,
                child: Sidebar(),
              ),
              Expanded(
                child: Obx(() => MessageFeed(id: controller.selectedConversation.value.id)),
              ),
            ],
          ),

          //* Notifications
          Obx(() =>
            Animate(
              target: notificationController.open.value ? 1 : 0,
              effects: [
                ScaleEffect(
                  curve: Curves.elasticOut,
                  duration: 400.ms,
                  begin: const Offset(0, 0)
                ), 
                FadeEffect(
                  curve: Curves.linear,
                  duration: 250.ms,
                  delay: 100.ms,
                  begin: 0
                ),
              ],
              child: Positioned(
                top: 50,
                right: 20,
                child: SizedBox(
                  width: 350,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    child: Material(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      child: Row(
                        children: [
                          Obx(() =>
                            Container(
                              width: 5,
                              height: 30,
                              color: notificationController.type.value.color,
                            ),
                          ),
                          horizontalSpacing(defaultSpacing),
                          Expanded(
                            child: Obx(() => Text(
                              notificationController.message.value,
                              style: theme.textTheme.bodyLarge,
                            )),
                          )
                        ],
                      )
                    ),
                  )
                )
              ),
            )
          ),
        ],
      )
    );
  }
}
