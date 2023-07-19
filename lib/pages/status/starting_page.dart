import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/vertical_spacing.dart';

class StartingPage extends StatefulWidget {
  const StartingPage({super.key});

  @override
  State<StartingPage> createState() => _StartingPageState();
}

class _StartingPageState extends State<StartingPage> {

  @override
  void initState() {
    if(setupManager.current == -1) {
      setupManager.next(open: false);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      body: Center(
        child: TransitionContainer(
          borderRadius: BorderRadius.circular(modelBorderRadius),
          fade: true,
          color: Get.theme.colorScheme.onBackground,
          width: 250,
          tag: "login",
          child: ClipRRect(
            borderRadius: BorderRadius.circular(modelBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    minHeight: 10,
                    color: Get.theme.colorScheme.primary,
                    backgroundColor: Get.theme.colorScheme.primaryContainer,
                  ),
                  //verticalSpacing(defaultSpacing),
                  //Obx(() => Text(setupManager.message.value.tr, style: Get.textTheme.labelLarge, )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}