import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/spaces/call_scroll.dart';
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
    SpacesController spaceController = Get.find();
    SettingController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(defaultSpacing * 0.5),
      child: Column(
        children: [
          //* Top preview
          Obx(
            () => Visibility(
              visible: controller.settings["call_app.expansionPosition"]!.getValue() == 0 && !spaceController.hideOverlay.value,
              child: Padding(
                padding: const EdgeInsets.only(bottom: defaultSpacing),
                child: CallScrollView(
                  hasVideo: spaceController.hasVideo,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Row(
              children: [
                //* Left preview
                Obx(
                  () => Visibility(
                    visible: controller.settings["call_app.expansionPosition"]!.getValue() == 3 && !spaceController.hideOverlay.value,
                    child: Padding(
                      padding: const EdgeInsets.only(right: defaultSpacing),
                      child: CallScrollView(
                        hasVideo: spaceController.hasVideo,
                        scrollDirection: Axis.vertical,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Obx(() => spaceController.cinemaWidget.value ?? Container()),
                ),

                //* Right preview
                Obx(
                  () => Visibility(
                    visible: controller.settings["call_app.expansionPosition"]!.getValue() == 1 && !spaceController.hideOverlay.value,
                    child: Padding(
                      padding: const EdgeInsets.only(left: defaultSpacing),
                      child: CallScrollView(
                        hasVideo: spaceController.hasVideo,
                        scrollDirection: Axis.vertical,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //* Bottom preview
          Obx(
            () => Visibility(
              visible: controller.settings["call_app.expansionPosition"]!.getValue() == 2 && !spaceController.hideOverlay.value,
              child: Padding(
                padding: const EdgeInsets.only(top: defaultSpacing),
                child: CallScrollView(
                  hasVideo: spaceController.hasVideo,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
