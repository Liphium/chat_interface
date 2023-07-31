import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestButton extends StatefulWidget {
  
  final Request request;

  const RequestButton({super.key, required this.request});

  @override
  State<RequestButton> createState() => _RequestButtonState();
}

class _RequestButtonState extends State<RequestButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: Theme.of(context)
            .colorScheme
            .secondaryContainer
            .withAlpha(150),
        splashColor: Theme.of(context)
            .colorScheme
            .secondaryContainer
            .withAlpha(150),
        onTap: () {},

        //* Request item content
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultSpacing,
              vertical: defaultSpacing * 0.5),
          child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                      Row(
                        children: [
                          Icon(Icons.person,
                              size: 30,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary),
                          const SizedBox(width: 10),
                          Text(
                              "${widget.request.name}#${widget.request.tag}",
                              style: Get.theme.textTheme.titleMedium),
                        ],
                      ),

                      //* Request actions
                      Obx(() => widget.request.loading.value ?

                      const SizedBox(
                        width: 25,
                        height: 25,
                        child: Padding(
                          padding: EdgeInsets.all(defaultSpacing * 0.25),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        ),
                      ) : 

                      //* Accept/decline
                      Row(
                        children: [

                          //* Accept request
                          IconButton(
                            icon: Icon(Icons.check,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary),
                            onPressed: () => sendLog("request accepted"),
                          ),
                          horizontalSpacing(defaultSpacing * 0.5),

                          //* Decline request
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary),
                            onPressed: () => sendLog("request denied"),
                          ),
                        ],
                      )),
                    ])),
        ),
      );
  }
}