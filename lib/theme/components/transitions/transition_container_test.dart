import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'transition_container_test2.dart';
import 'transition_controller.dart';

class AnimatedContainerTestPage extends StatelessWidget {
  const AnimatedContainerTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.inverseSurface,
      body: Center(
        child: TransitionContainer(
          tag: "test",
          color: theme.colorScheme.onInverseSurface,
          child: InkWell(
              onTap: () => Get.find<TransitionController>().modelTransition(const AnimatedContainerTestPage2()),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Hello world.", style: TextStyle(color: Colors.white)),
                  Text("Hello world.", style: TextStyle(color: Colors.white)),
                  Text("Hello world.", style: TextStyle(color: Colors.white)),
                  Text("Hello world.", style: TextStyle(color: Colors.white)),
                  Text("Hello world.", style: TextStyle(color: Colors.white)),
                ],
              )),
        ),
      ),
    );
  }
}
