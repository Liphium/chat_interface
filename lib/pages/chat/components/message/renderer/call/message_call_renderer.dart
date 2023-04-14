import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:chat_interface/controller/chat/conversation/message_controller.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;

part 'call_actions.dart';

class CallMessageRenderer extends StatefulWidget {

  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;

  const CallMessageRenderer({super.key, required this.message, this.self = false, this.last = false, this.sender});

  @override
  State<CallMessageRenderer> createState() => _CallMessageRendererState();
}

class _CallMessageRendererState extends State<CallMessageRenderer> {

  final loading = false.obs;

  @override
  Widget build(BuildContext context) {

    Friend sender = widget.sender ?? Friend(0, "System", "", "fjc");
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: !widget.last ? defaultSpacing : 0),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        splashColor: theme.hoverColor,
        onTap: () => {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: defaultSpacing * 0.4,
            horizontal: defaultSpacing * 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Row(
                  children: [

                    //* Call message
                    Material(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing * 0.5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            horizontalSpacing(defaultSpacing * 0.5),
                            const Icon(Icons.call, size: 25),
                            horizontalSpacing(defaultSpacing),
                            Text("call.message", style: theme.textTheme.bodyLarge),
                            horizontalSpacing(defaultSpacing * 1.5),
                            Material(
                              borderRadius: BorderRadius.circular(defaultSpacing),
                              color: theme.colorScheme.primaryContainer,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(defaultSpacing),
                                splashColor: theme.hoverColor,
                                onTap: () {
                                  if(loading.value) return;

                                  joinCall(loading, widget.message.conversation, widget.message.attachments);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(defaultSpacing),
                                  child: Text("join.call".tr, style: theme.textTheme.labelLarge),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    Expanded(child: Container())
                  ],
                ),
              ),

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
      ),
    );
  }
}