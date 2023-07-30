import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/ui/containers/success_container.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final revealSuccess = false.obs;
  var message = "";

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
                        Obx(() =>
                          Animate(
                            effects: [
                              CustomEffect(
                                duration: 250.ms,
                                builder: (context, value, child) {
                                  return SizedBox(
                                    height: (50 + defaultSpacing) * value,
                                    child: child,
                                  );
                                },
                              ),
                              ScaleEffect(
                                begin: const Offset(0.0, 0.0),
                                end: const Offset(1.0, 1.0),
                                duration: 500.ms,
                                curve: const ElasticOutCurve(0.9),
                                delay: 250.ms,
                              )
                            ],
                            target: revealSuccess.value ? 1 : 0,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: defaultSpacing),
                              child: SuccessContainer(text: message.tr)
                            ),
                          )
                        ),
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

                            newFriendRequest(args[0], args[1], (message) {
                              this.message = message;
                              revealSuccess.value = true;
                              _controller.clear();
                            });
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