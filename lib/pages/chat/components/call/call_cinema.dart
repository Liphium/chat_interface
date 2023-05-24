import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:chat_interface/pages/chat/components/call/call_scroll.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallCinemaView extends StatefulWidget {

  const CallCinemaView({super.key});

  @override
  State<CallCinemaView> createState() => _CallCinemaViewState();
}

class _CallCinemaViewState extends State<CallCinemaView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Will be needed soon

    CallController callController = Get.find();
    SettingController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(defaultSpacing * 0.5),
      child: Column(
        children: [

          //* Top preview
          Obx(() =>
            Visibility(
              visible: controller.settings["call_app.expansionPosition"]!.getValue() == 0 && !callController.hideOverlay.value,
              child: Padding(
                padding: const EdgeInsets.only(bottom: defaultSpacing),
                child: CallScrollView(
                  hasVideo: callController.hasVideo,
                  scrollDirection: Axis.horizontal,
                )
              )
            )
          ),
          
          Expanded(
            flex: 3,
            child: Row(
              children: [

                //* Left preview
                Obx(() =>
                  Visibility(
                    visible: controller.settings["call_app.expansionPosition"]!.getValue() == 3 && !callController.hideOverlay.value,
                    child: Padding(
                      padding: const EdgeInsets.only(right: defaultSpacing),
                      child: CallScrollView(
                        hasVideo: callController.hasVideo,
                        scrollDirection: Axis.vertical,
                      )
                    )
                  )
                ),

                Expanded(
                  flex: 3,
                  child: Hero(
                    tag: "mainframe",
                    child: Obx(() => callController.cinemaWidget.value ?? Container()),
                  ),
                ),

                //* Right preview
                Obx(() =>
                  Visibility(
                    visible: controller.settings["call_app.expansionPosition"]!.getValue() == 1 && !callController.hideOverlay.value,
                    child: Padding(
                      padding: const EdgeInsets.only(left: defaultSpacing),
                      child: CallScrollView(
                        hasVideo: callController.hasVideo,
                        scrollDirection: Axis.vertical,
                      )
                    )
                  )
                ),
              ],
            ),
          ),

          //* Bottom preview
          Obx(() =>
            Visibility(
              visible: controller.settings["call_app.expansionPosition"]!.getValue() == 2 && !callController.hideOverlay.value,
              child: Padding(
                padding: const EdgeInsets.only(top: defaultSpacing),
                child: CallScrollView(
                  hasVideo: callController.hasVideo,
                  scrollDirection: Axis.horizontal,
                )
              )
            )
          ),
        ],
      ),
    );
  }
}