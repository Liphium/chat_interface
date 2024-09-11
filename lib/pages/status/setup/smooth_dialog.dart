import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SmoothDialogController {
  final widgetOne = Rx<Widget?>(null);
  final widgetTwo = Rx<Widget?>(null);
  late AnimationController _one, _two;
  Future? transitionComplete;

  SmoothDialogController(Widget child) {
    widgetTwo.value = child;
  }

  void init(AnimationController one, AnimationController two) {
    _one = one;
    _two = two;
  }

  static const curve = Curves.easeInOutQuart;
  void transitionTo(Widget widget) async {
    await transitionComplete;
    widgetOne.value = widgetTwo.value;
    widgetTwo.value = widget;
    _two.value = 0;
    _two.animateTo(1, duration: 750.ms, curve: curve);
    _one.value = 1;
    _one.animateBack(0.0, duration: 750.ms, curve: curve);
    transitionComplete = Future.delayed(750.ms);
  }
}

class SmoothDialog extends StatefulWidget {
  final SmoothDialogController controller;

  const SmoothDialog({super.key, required this.controller});

  @override
  State<SmoothDialog> createState() => _SmoothDialogState();
}

class _SmoothDialogState extends State<SmoothDialog> with TickerProviderStateMixin {
  late AnimationController _one, _two;

  @override
  void initState() {
    _one = AnimationController(vsync: this, duration: 2000.ms);
    _two = AnimationController(vsync: this, duration: 2000.ms);
    _one.stop();
    _one.value = 0;
    _two.stop();
    _two.value = 1;
    widget.controller.init(_one, _two);

    super.initState();
  }

  @override
  void dispose() {
    _one.dispose();
    _two.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 370),
          child: Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(sectionSpacing),
            ),
            padding: const EdgeInsets.symmetric(horizontal: sectionSpacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Animate(
                  controller: _one,
                  autoPlay: false,
                  effects: [
                    ExpandEffect(
                      axis: Axis.vertical,
                      alignment: Alignment.bottomCenter,
                    ),
                    const BlurEffect(
                      begin: Offset(5, 5),
                      end: Offset(0, 0),
                    ),
                    const ScaleEffect(
                      begin: Offset(0.5, 0.5),
                      end: Offset(1, 1),
                    ),
                  ],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      verticalSpacing(sectionSpacing),
                      Obx(() => widget.controller.widgetOne.value ?? const SizedBox()),
                      verticalSpacing(sectionSpacing),
                    ],
                  ),
                ),
                Animate(
                  controller: _two,
                  autoPlay: false,
                  effects: [
                    ExpandEffect(
                      axis: Axis.vertical,
                      alignment: Alignment.topCenter,
                    ),
                    const ScaleEffect(
                      begin: Offset(0.5, 0.5),
                      end: Offset(1, 1),
                    ),
                  ],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      verticalSpacing(sectionSpacing),
                      Obx(() => widget.controller.widgetTwo.value!),
                      verticalSpacing(sectionSpacing),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
