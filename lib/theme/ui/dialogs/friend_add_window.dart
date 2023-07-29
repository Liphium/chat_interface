import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/vertical_spacing.dart';

class FriendAddWindow extends StatefulWidget {

  final Offset position;
  
  const FriendAddWindow({super.key, required this.position});

  @override
  State<FriendAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<FriendAddWindow> {

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Positioned(
          top: widget.position.dy,
          left: widget.position.dx,
          child: SizedBox(
            width: 300,
            child: Material(
              elevation: 2.0,
              color: Get.theme.colorScheme.onBackground,
              borderRadius: BorderRadius.circular(dialogBorderRadius),
              child: Padding(
                padding: const EdgeInsets.all(dialogPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            
                    Text("friend.add".tr, style: Get.theme.textTheme.titleMedium),
            
                    verticalSpacing(sectionSpacing),
            
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FJTextField(
                          controller: _controller,
                          hintText: "input.username".tr,  
                        ),
                        verticalSpacing(defaultSpacing),
                        FJElevatedLoadingButton(
                          loading: requestsLoading,
                          onTap: () {
                            var args = _controller.text.split("#");
                            if (args.length != 2) {
                              showErrorPopup("request.not.found", "request.not.found.text");
                              return;
                            }

                            newFriendRequest(args[0], args[1]);
                          }, 
                          label: "request.send",
                        )
                      ],
                    )
                  ],
                ),
              )
            ),
          )
        )
      ]
    );
  }
}