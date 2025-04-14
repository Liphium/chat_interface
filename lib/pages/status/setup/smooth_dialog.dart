import 'dart:async';
import 'dart:math';

import 'package:chat_interface/pages/status/setup/setup_page.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SmoothDialogController {
  final Duration duration;
  final widgetOne = signal<Widget?>(null);
  final widgetTwo = signal<Widget?>(null);
  late AnimationController _one, _two;
  Future? transitionComplete;
  var keyOne = Random().nextDouble();
  var keyTwo = Random().nextDouble();
  bool direction = true;

  SmoothDialogController(Widget child, {this.duration = const Duration(milliseconds: 750)}) {
    widgetTwo.value = child;
  }

  void init(AnimationController one, AnimationController two) {
    _one = one;
    _two = two;
  }

  /// Dispose the signals powering the smooth dialog controller.
  void dispose() {
    widgetOne.dispose();
    widgetTwo.dispose();
  }

  static const curve = Curves.easeInOutQuart;
  Future<void> transitionTo(Widget widget) async {
    await transitionComplete;
    direction = !direction;
    if (direction) {
      _two.value = 0;
      unawaited(_two.animateTo(1, duration: duration, curve: curve));
      _one.value = 1;
      unawaited(_one.animateBack(0.0, duration: duration, curve: curve));
      widgetTwo.value = widget;
    } else {
      _one.value = 0;
      unawaited(_one.animateTo(1, duration: duration, curve: curve));
      _two.value = 1;
      unawaited(_two.animateBack(0.0, duration: duration, curve: curve));
      widgetOne.value = widget;
    }
    transitionComplete = Future.delayed(duration);
  }

  Future<void> transitionToContinuos(Widget widget) async {
    await transitionComplete;
    direction = !direction;
    final widgetToClone = widgetTwo.value;
    widgetOne.value = widgetToClone;
    widgetTwo.value = widget;
    _two.value = 0;
    unawaited(_two.animateTo(1, duration: duration, curve: curve));
    _one.value = 1;
    unawaited(_one.animateBack(0.0, duration: duration, curve: curve));
    transitionComplete = Future.delayed(duration);
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Animate(
                  controller: _one,
                  autoPlay: false,
                  effects: [
                    ExpandEffect(axis: Axis.vertical, alignment: Alignment.bottomCenter),
                    const BlurEffect(begin: Offset(5, 5), end: Offset(0, 0)),
                    const ScaleEffect(begin: Offset(0.5, 0.5), end: Offset(1, 1)),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(sectionSpacing),
                    child: Watch(
                      (ctx) => SizedBox(
                        key: ValueKey(widget.controller.keyOne),
                        child: widget.controller.widgetOne.value ?? const SizedBox(),
                      ),
                    ),
                  ),
                ),
                Animate(
                  controller: _two,
                  autoPlay: false,
                  effects: [
                    ExpandEffect(axis: Axis.vertical, alignment: Alignment.topCenter),
                    const BlurEffect(begin: Offset(5, 5), end: Offset(0, 0)),
                    const ScaleEffect(begin: Offset(0.5, 0.5), end: Offset(1, 1)),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(sectionSpacing),
                    child: Watch(
                      (ctx) => SizedBox(
                        key: ValueKey(widget.controller.keyTwo),
                        child: widget.controller.widgetTwo.value!,
                      ),
                    ),
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

class SmoothDialogWindow extends StatefulWidget {
  final SmoothDialogController controller;

  const SmoothDialogWindow({super.key, required this.controller});

  @override
  State<SmoothDialogWindow> createState() => _SmoothDialogWindowState();
}

class _SmoothDialogWindowState extends State<SmoothDialogWindow> with TickerProviderStateMixin {
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 370),
        child: Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.onInverseSurface,
            borderRadius: BorderRadius.circular(sectionSpacing),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Animate(
                controller: _one,
                autoPlay: false,
                effects: [
                  ExpandEffect(axis: Axis.vertical, alignment: Alignment.bottomCenter),
                  const BlurEffect(begin: Offset(5, 5), end: Offset(0, 0)),
                  const ScaleEffect(begin: Offset(0.5, 0.5), end: Offset(1, 1)),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(sectionSpacing),
                  child: Watch(
                    (ctx) => SizedBox(
                      key: ValueKey(widget.controller.keyOne),
                      child: widget.controller.widgetOne.value ?? const SizedBox(),
                    ),
                  ),
                ),
              ),
              Animate(
                controller: _two,
                autoPlay: false,
                effects: [
                  ExpandEffect(axis: Axis.vertical, alignment: Alignment.topCenter),
                  const BlurEffect(begin: Offset(5, 5), end: Offset(0, 0)),
                  const ScaleEffect(begin: Offset(0.5, 0.5), end: Offset(1, 1)),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(sectionSpacing),
                  child: Watch(
                    (ctx) => SizedBox(
                      key: ValueKey(widget.controller.keyTwo),
                      child: widget.controller.widgetTwo.value!,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SmoothBox extends StatefulWidget {
  final SmoothDialogController controller;

  const SmoothBox({super.key, required this.controller});

  @override
  State<SmoothBox> createState() => _SmoothBoxState();
}

class _SmoothBoxState extends State<SmoothBox> with TickerProviderStateMixin {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Animate(
          controller: _one,
          autoPlay: false,
          effects: [
            ExpandEffect(axis: Axis.vertical, alignment: Alignment.bottomCenter),
            const FadeEffect(begin: 0, end: 1, curve: Curves.linear),
          ],
          child: Watch(
            (ctx) => SizedBox(
              key: ValueKey(widget.controller.keyOne),
              child: widget.controller.widgetOne.value ?? const SizedBox(),
            ),
          ),
        ),
        Animate(
          controller: _two,
          autoPlay: false,
          effects: [
            ExpandEffect(axis: Axis.vertical, alignment: Alignment.topCenter),
            const FadeEffect(begin: 0, end: 1),
          ],
          child: Watch(
            (ctx) => SizedBox(
              key: ValueKey(widget.controller.keyTwo),
              child: widget.controller.widgetTwo.value!,
            ),
          ),
        ),
      ],
    );
  }
}

class SmoothDialogTest extends StatefulWidget {
  const SmoothDialogTest({super.key});

  @override
  State<SmoothDialogTest> createState() => _SmoothDialogTestState();
}

class _SmoothDialogTestState extends State<SmoothDialogTest> {
  final controller = SmoothDialogController(
    const SetupLoadingWidget(text: "Welcome to this experiment!"),
  );

  @override
  void initState() {
    Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      controller.transitionTo(
        Builder(
          builder: (context) {
            return SetupLoadingWidget(text: "Hi ${Random().nextDouble().toStringAsFixed(2)}");
          },
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SmoothDialog(controller: controller);
  }
}

class SmoothDialogBoxTest extends StatefulWidget {
  const SmoothDialogBoxTest({super.key});

  @override
  State<SmoothDialogBoxTest> createState() => _SmoothDialogBoxTestState();
}

class _SmoothDialogBoxTestState extends State<SmoothDialogBoxTest> {
  final controller = SmoothDialogController(
    const SetupLoadingWidget(text: "Welcome to this experiment!"),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: Center(
        child: FJElevatedButton(
          onTap: () async {
            var timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
              controller.transitionTo(
                Builder(
                  builder: (context) {
                    return SetupLoadingWidget(
                      text: "Hi ${Random().nextDouble().toStringAsFixed(2)}",
                    );
                  },
                ),
              );
            });

            await Get.dialog(SmoothDialogWindow(controller: controller));
            timer.cancel();
          },
          child: Text("Open dialog", style: Get.textTheme.labelLarge),
        ),
      ),
    );
  }
}
