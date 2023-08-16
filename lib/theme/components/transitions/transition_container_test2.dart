import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/theme/components/transitions/transition_container_test.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedContainerTestPage2 extends StatelessWidget {
  const AnimatedContainerTestPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: TransitionContainer(
          tag: "test",
          color: theme.colorScheme.onBackground,
          child: InkWell(
            onTap: () => Get.find<TransitionController>().modelTransition(const AnimatedContainerTestPage()),
            child: const Text("Hello world.", style: TextStyle(color: Colors.white))
          ),
        ),
      ),
    );
  }
}