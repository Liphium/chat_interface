import 'package:chat_interface/controller/chat/message_controller.dart';
import 'package:chat_interface/controller/current/notification_controller.dart' as nc;
import 'package:chat_interface/pages/chat/message_feed.dart';
import 'package:chat_interface/pages/chat/notifications/notification_renderer.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
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
    nc.NotificationController notificationController = Get.find();

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
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing * 2),
              child: Padding(
                padding: const EdgeInsets.only(top: defaultSpacing * 4),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Obx(() => ListView.builder(
                    itemCount: notificationController.notifications.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final nc.Notification notification = notificationController.notifications[index];
          
                      return UnconstrainedBox(child: NotificationRenderer(notification: notification));
                    },
                  )),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
