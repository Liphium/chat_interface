import 'package:chat_interface/pages/chat/messages/message_formatter.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputDemo extends StatefulWidget {
  const InputDemo({super.key});

  @override
  State<InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<InputDemo> {
  final MessageFormatter formatter = MessageFormatter(Get.theme.textTheme.labelLarge!, Get.theme.textTheme.bodyLarge!);
  final text = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return RichText(text: formatter.build(text.value));
              }),
              verticalSpacing(sectionSpacing),
              FJTextField(
                onChange: (value) => text.value = value,
              )
            ],
          ),
        ),
      ),
    );
  }
}
