import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPageMobile extends StatefulWidget {
  const ChatPageMobile({super.key});

  @override
  State<ChatPageMobile> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPageMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: PlatformCallback(
        desktop: () {
          Get.off(const ChatPageDesktop());
        },
        child: const Sidebar(),
      ),
    );
  }
}
