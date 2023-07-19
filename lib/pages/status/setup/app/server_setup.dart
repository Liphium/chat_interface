import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServerSetup extends Setup {
  ServerSetup() : super('loading.server', true);

  @override
  Future<Widget?> load() async {
    return const ServerSelectorPage();
  }
}

class ServerSelectorPage extends StatelessWidget {
  const ServerSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      body: Center(
        child: TransitionContainer(
          tag: "login",
          borderRadius: BorderRadius.circular(modelBorderRadius),
          width: 370,
          child: Padding(
            padding: const EdgeInsets.all(modelPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${'setup.choose.server'.tr}.", style: Get.textTheme.headlineMedium,),
                verticalSpacing(sectionSpacing),
                SizedBox(
                  width: double.infinity,
                  child: FJElevatedButton(
                    onTap: () => setupManager.next(),
                    child: Center(child: Text("Localhost", style: Get.theme.textTheme.labelLarge)),
                  ),
                ),
                verticalSpacing(defaultSpacing),
                SizedBox(
                  width: double.infinity,
                  child: FJElevatedButton(
                    onTap: () {
                      basePath = 'http://server.fajurion.com:3000';
                      setupManager.next();
                    },
                    child: Center(child: Text('Fajurion network', style: Get.theme.textTheme.labelLarge)),
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