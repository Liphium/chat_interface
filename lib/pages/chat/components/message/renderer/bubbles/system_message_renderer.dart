import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BubblesSystemMessageRenderer extends StatefulWidget {
  final Message message;
  final MessageProvider provider;
  final bool self;
  final bool last;

  const BubblesSystemMessageRenderer({
    super.key,
    required this.message,
    required this.provider,
    this.self = false,
    this.last = false,
  });

  @override
  State<BubblesSystemMessageRenderer> createState() => _MessageRendererState();
}

class _MessageRendererState extends State<BubblesSystemMessageRenderer> {
  @override
  Widget build(BuildContext context) {
    final message = SystemMessages.messages[widget.message.content]!;

    return Padding(
      padding: const EdgeInsets.only(top: defaultSpacing),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: elementSpacing,
          horizontal: sectionSpacing,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //* Icon
            SizedBox(
              width: 50,
              child: Center(child: Icon(message.icon, size: 30, color: Get.theme.colorScheme.onPrimary)),
            ),
            horizontalSpacing(defaultSpacing),

            //* Space info
            Flexible(
              child: Text(
                message.translation.call(widget.message, widget.provider),
                style: Get.theme.textTheme.labelLarge,
                overflow: TextOverflow.visible,
              ),
            ),

            horizontalSpacing(defaultSpacing),
          ],
        ),
      ),
    );
  }
}
