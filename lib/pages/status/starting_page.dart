import 'package:chat_interface/pages/status/setup/setup_manager.dart';
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
    setupManager.next();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/img/logo.png",
            width: 200.0,
          ),
          verticalSpacing(defaultSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text(setupManager.message.value.tr)),
              horizontalSpacing(defaultSpacing * 2),
              const SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                )
              ),
            ],
          )
        ],
      ),
    );
  }
}