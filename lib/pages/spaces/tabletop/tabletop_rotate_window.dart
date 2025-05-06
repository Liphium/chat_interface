import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_page.dart';
import 'package:chat_interface/theme/components/forms/fj_slider.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:signals/signals_flutter.dart';

class TabletopRotateWindow extends StatefulWidget {
  final ContextMenuData data;

  const TabletopRotateWindow({super.key, required this.data});

  @override
  State<TabletopRotateWindow> createState() => _TabletopRotateWindowState();
}

class _TabletopRotateWindowState extends State<TabletopRotateWindow> {
  @override
  Widget build(BuildContext context) {
    return SlidingWindowBase(
      title: const [], // Only for mobile (sort of)
      position: widget.data,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rotation", style: Get.theme.textTheme.labelLarge),
          Watch(
            (context) => FJSliderWithInput(
              value: TabletopController.canvasRotation.value,
              onChanged: (value) {
                rotateTable(value);
              },
              min: 0,
              max: 2 * math.pi,
              transformer: (value) => value * (360.0 / (2.0 * math.pi)),
              reverseTransformer: (value) => value * ((2.0 * math.pi) / 360.0),
            ),
          ),
          Row(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: defaultSpacing),
                child: Material(
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  color: Get.theme.colorScheme.inverseSurface,
                  child: InkWell(
                    onTap: () => rotateTable(math.pi / 2 * (index + 1)),
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    child: Padding(
                      padding: const EdgeInsets.all(defaultSpacing),
                      child: Row(
                        children: [
                          Icon(Icons.rotate_left, color: Get.theme.colorScheme.onPrimary),
                          horizontalSpacing(elementSpacing),
                          Text("${90 * (index + 1)}", style: Get.theme.textTheme.labelMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void rotateTable(double value) {
    final canvasWidth = Get.width - TabletopController.globalCanvasPosition.dx;
    final canvasHeight = Get.height - TabletopController.globalCanvasPosition.dy;
    final center = Offset(canvasWidth / 2, canvasHeight / 2);
    final focalPoint = TabletopView.localToWorldPos(
      center,
      TabletopController.canvasZoom,
      TabletopController.canvasOffset,
    );
    TabletopController.canvasRotation.value = value;
    final newFocalPoint = TabletopView.localToWorldPos(
      center,
      TabletopController.canvasZoom,
      TabletopController.canvasOffset,
    );

    TabletopController.canvasOffset -= focalPoint - newFocalPoint;
  }
}
