import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestButton extends StatefulWidget {
  final bool self; // If the request was sent by the user
  final Request request;

  const RequestButton({super.key, required this.request, required this.self});

  @override
  State<RequestButton> createState() => _RequestButtonState();
}

class _RequestButtonState extends State<RequestButton> {
  final requestLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    //* Accept/decline buttons
    final children = <Widget>[
      IconButton(
        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary),
        onPressed: () =>
            widget.self ? widget.request.cancel() : widget.request.ignore(),
      )
    ];

    // Add accept button if request is for self
    if (!widget.self) {
      children.insert(0, horizontalSpacing(defaultSpacing * 0.5));
      children.insert(
          0,
          LoadingIconButton(
            loading: requestLoading,
            icon: Icons.check,
            color: Get.theme.colorScheme.onPrimary,
            onTap: () {
              requestLoading.value = true;
              widget.request.accept((p0) {
                sendLog("Request accepted");
                requestLoading.value = false;
              });
            },
          ));
    }

    return Material(
      borderRadius: BorderRadius.circular(defaultSpacing),
      color: Get.theme.colorScheme.onBackground,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultSpacing),

        //* Request item content
        child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.email,
                          size: 30,
                          color: Theme.of(context).colorScheme.onPrimary),
                      const SizedBox(width: 10),
                      Text("${widget.request.name}#${widget.request.tag}",
                          style: Get.theme.textTheme.titleMedium),
                    ],
                  ),

                  //* Request actions
                  Obx(() => widget.request.loading.value
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: Padding(
                            padding: EdgeInsets.all(defaultSpacing * 0.25),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                          ),
                        )
                      :

                      //* Accept/decline
                      Row(
                          children: children,
                        )),
                ])),
      ),
    );
  }
}
