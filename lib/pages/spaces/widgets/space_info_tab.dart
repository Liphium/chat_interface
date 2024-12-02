import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpaceInfoTab extends StatelessWidget {
  const SpaceInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700 + sectionSpacing * 2,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: sectionSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(75),
              Text("spaces.welcome".tr, style: Get.textTheme.headlineMedium),
              verticalSpacing(sectionSpacing),
              Text("spaces.welcome.desc".tr, style: Get.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
