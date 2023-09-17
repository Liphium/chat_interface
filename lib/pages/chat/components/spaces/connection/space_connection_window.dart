import 'package:chat_interface/pages/chat/chat_page.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpaceConnectionWindow extends StatefulWidget {
  
  const SpaceConnectionWindow({super.key});

  @override
  State<SpaceConnectionWindow> createState() => _SpaceConnectionWindowState();
}

class _SpaceConnectionWindowState extends State<SpaceConnectionWindow> {

  @override
  Widget build(BuildContext context) {

    Future.delayed(1.seconds, () {
      Get.offAll(const ChatPage(), transition: Transition.fadeIn);
    });

    return Center(
      child: SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(modelPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("connecting to your space..", style: Get.theme.textTheme.titleMedium),
              verticalSpacing(defaultSpacing),
              Text("wait a little..", style: Get.theme.textTheme.bodyMedium),
              verticalSpacing(sectionSpacing),
              FJElevatedButton(
                onTap: () => Get.back(), 
                child: Center(child: Text("ok".tr, style: Get.theme.textTheme.titleMedium),)
              )
            ],
          ),
        ),
      ),
    );
  }
}