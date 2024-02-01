import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

enum CallOverlayPosition {
  top(2),
  right(3),
  bottom(0),
  left(1);

  final int _opposite;

  const CallOverlayPosition(this._opposite);

  CallOverlayPosition get opposite => CallOverlayPosition.values[_opposite];
}

enum CallOverlayAlignment { start, end }

class CallPositionOverlay extends StatefulWidget {
  final RxBool show;
  final CallOverlayPosition position;
  final CallOverlayAlignment alignment;

  const CallPositionOverlay(
      {super.key,
      required this.position,
      required this.alignment,
      required this.show});

  @override
  State<CallPositionOverlay> createState() => _CallPositionOverlayState();
}

class _CallPositionOverlayState extends State<CallPositionOverlay> {
  @override
  Widget build(BuildContext context) {
    SpacesController spacesController = Get.find();
    SettingController controller = Get.find();
    ThemeData theme = Theme.of(context);

    int current = controller.settings["call_app.expansionPosition"]!.getValue();

    // Check if the current value is horizontal or vertical
    final Alignment alignment;
    final bool horizontal = (current + 1) % 2 == 0;
    if (horizontal) {
      alignment = widget.alignment == CallOverlayAlignment.start
          ? Alignment.topCenter
          : Alignment.bottomCenter;
    } else {
      alignment = widget.alignment == CallOverlayAlignment.start
          ? Alignment.centerLeft
          : Alignment.centerRight;
    }

    return Obx(() => Animate(
          target: widget.show.value ? 1.0 : 0.0,
          effects: [
            ScaleEffect(
              duration: 500.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
            ),
            FadeEffect(
              duration: 200.ms,
              curve: Curves.easeIn,
            )
          ],
          child: Align(
            alignment: alignment,
            child: Material(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(defaultSpacing),
              child: Padding(
                  padding: const EdgeInsets.all(defaultSpacing * 0.25),
                  child: horizontal
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection:
                              widget.position == CallOverlayPosition.right
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                          children: [
                            horizontalButton(controller, widget.position),
                            horizontalSpacing(defaultSpacing * 0.5),
                            hideOverlayButton(spacesController),
                            horizontalSpacing(defaultSpacing * 0.5),
                            verticalButton(
                                controller,
                                widget.alignment == CallOverlayAlignment.start
                                    ? CallOverlayPosition.bottom
                                    : CallOverlayPosition.top),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          verticalDirection:
                              widget.position == CallOverlayPosition.top
                                  ? VerticalDirection.up
                                  : VerticalDirection.down,
                          children: [
                            verticalButton(controller, widget.position),
                            verticalSpacing(defaultSpacing * 0.5),
                            hideOverlayButton(spacesController),
                            verticalSpacing(defaultSpacing * 0.5),
                            horizontalButton(
                                controller,
                                widget.alignment == CallOverlayAlignment.start
                                    ? CallOverlayPosition.right
                                    : CallOverlayPosition.left),
                          ],
                        )),
            ),
          ),
        ));
  }

  Widget horizontalButton(
      SettingController controller, CallOverlayPosition position) {
    return IconButton(
        onPressed: () => controller.settings["call_app.expansionPosition"]!
            .setValue(position == CallOverlayPosition.right ? 3 : 1),
        icon: Icon(
          position == CallOverlayPosition.right
              ? Icons.arrow_back
              : Icons.arrow_forward,
          size: 25,
        ));
  }

  Widget verticalButton(
      SettingController controller, CallOverlayPosition position) {
    return IconButton(
        onPressed: () => controller.settings["call_app.expansionPosition"]!
            .setValue(position == CallOverlayPosition.top ? 2 : 0),
        icon: Icon(
          position == CallOverlayPosition.top
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          size: 25,
        ));
  }

  Widget hideOverlayButton(SpacesController callController) => IconButton(
      onPressed: () => {} /* callController.hideOverlay.toggle() */,
      icon: const Icon(
          /* callController.hideOverlay.value ? Icons.unfold_more : Icons.unfold_less */ Icons
              .unfold_less,
          size: 25,
          color: Colors.amber));
}
