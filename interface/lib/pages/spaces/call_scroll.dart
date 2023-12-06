import 'dart:ui';

import 'package:chat_interface/pages/spaces/entities/entity_renderer.dart';
import 'package:chat_interface/pages/spaces/widgets/call_scroll_overlay.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallScrollView extends StatefulWidget {

  final RxBool hasVideo;
  final Axis scrollDirection;
  final double maxWidth;
  final double maxHeight;

  const CallScrollView({super.key, required this.hasVideo, required this.scrollDirection, this.maxWidth = 300, this.maxHeight = 170});

  @override
  State<CallScrollView> createState() => _CallScrollViewState();
}

class _CallScrollViewState extends State<CallScrollView> {

  final show = false.obs;

  @override
  Widget build(BuildContext context) {

    SettingController controller = Get.find();

    return MouseRegion(
      onEnter: (event) => show.value = true,
      onExit: (event) => show.value = false,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.stylus
                  },
                ),
                child: SingleChildScrollView(
                  scrollDirection: widget.scrollDirection,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                  child: Padding(
    
                    // Horizontal/vertical padding
                    padding: widget.scrollDirection == Axis.horizontal ?
                      const EdgeInsets.symmetric(vertical: defaultSpacing * 2) :
                      const EdgeInsets.symmetric(horizontal: defaultSpacing * 2),
    
                    child: widget.scrollDirection == Axis.vertical ? 
                    
                    //* Vertical
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: renderEntites(defaultSpacing * 1.5, 0, BoxConstraints(
                        maxWidth: constraints.maxWidth - defaultSpacing * 3,
                        maxHeight: widget.maxHeight,
                      )),
                    ) :
                  
                    //* Horizontal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: renderEntites(0, defaultSpacing * 1.5, BoxConstraints(
                        maxHeight: constraints.maxHeight - defaultSpacing * 3,
                        maxWidth: widget.maxWidth,
                      )),
                    ),
                  ),
                ),
              );
            }
          ),
    
          //* Overlay
          Positioned.fill(
            child: CallPositionOverlay(
              position: CallOverlayPosition.values[controller.settings["call_app.expansionPosition"]!.getValue()],
              alignment: CallOverlayAlignment.start,
              show: show,
            )
          ),
    
          Positioned.fill(
            child: CallPositionOverlay(
              position: CallOverlayPosition.values[controller.settings["call_app.expansionPosition"]!.getValue()],
              alignment: CallOverlayAlignment.end,
              show: show,
            )
          )
        ],
      ),
    );
  }
}