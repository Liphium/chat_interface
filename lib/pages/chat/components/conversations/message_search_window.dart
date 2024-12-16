import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageSearchWindow extends StatefulWidget {
  const MessageSearchWindow({super.key});

  @override
  State<MessageSearchWindow> createState() => _MessageSearchWindowState();
}

class _MessageSearchWindowState extends State<MessageSearchWindow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.theme.colorScheme.onInverseSurface,
      padding: EdgeInsets.symmetric(vertical: defaultSpacing, horizontal: sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FJTextField(
            prefixIcon: Icons.search,
            hintText: "search".tr,
          )
        ],
      ),
    );
  }
}
