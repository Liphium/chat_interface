import 'dart:async';

import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ErrorPage extends StatefulWidget {

  final String title;

  const ErrorPage({super.key, required this.title});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {

  Timer? _timer;
  var _start = 30.0;
  final _progress = 0.0.obs;

  @override
  void initState() {
    int duration = 10;

    _timer = Timer.periodic(
      duration.ms,
      (timer) {
        if (_start <= 0) {
          timer.cancel();
          setupManager.restart();
        } else {
          _start -= duration / 1000;
          _progress.value = _start / 30;
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      body: Center(
        child: TransitionContainer(
          tag: "login",
          borderRadius: BorderRadius.circular(modelBorderRadius),
          color: Get.theme.colorScheme.onBackground,
          width: 370,
          child: Padding(
            padding: const EdgeInsets.all(modelPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title.tr, style: Get.textTheme.headlineMedium,),
                verticalSpacing(sectionSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(() => Row(
                      children: [
                        SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            backgroundColor: Get.theme.colorScheme.primary,
                            color: Get.theme.colorScheme.onPrimary,
                            value: _progress.value,
                            strokeWidth: 2,
                          ),
                        ),
                        horizontalSpacing(defaultSpacing * 2),
                        Text("${'retry.text.1'.tr} "),
                        Text('${_start.toInt()}'),
                        Text(" ${'retry.text.2'.tr}"),
                      ],
                    )),
                  ],
                ),
                verticalSpacing(defaultSpacing),
                FJElevatedButton(
                  onTap: () => setupManager.restart(),
                  child: Center(child: Text('retry'.tr, style: Get.textTheme.labelLarge)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
