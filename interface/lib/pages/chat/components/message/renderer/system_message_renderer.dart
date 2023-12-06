
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SystemMessageRenderer extends StatefulWidget {

  final String accountId;
  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;

  const SystemMessageRenderer({super.key, required this.message, required this.accountId, this.self = false, this.last = false, this.sender});

  @override
  State<SystemMessageRenderer> createState() => _MessageRendererState();
}

class _MessageRendererState extends State<SystemMessageRenderer> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //* Icon
            SizedBox(
              width: 50,
              child: Center(child: Icon(message.icon, size: 30, color: Get.theme.colorScheme.onPrimary)),
            ),
            horizontalSpacing(sectionSpacing),

            //* Space info
            Expanded(child: Text(message.translation.call(widget.message), style: Get.theme.textTheme.labelLarge, overflow: TextOverflow.visible,)),

            horizontalSpacing(defaultSpacing),

            Visibility(
              visible: !widget.message.verified,
              child: Tooltip(
                message: "not.signed".tr,
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.amber,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}