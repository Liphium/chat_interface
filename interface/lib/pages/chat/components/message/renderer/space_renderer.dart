import 'dart:math';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpaceRenderer extends StatefulWidget {

  final bool requestOnInit;
  final SpaceConnectionContainer container;

  const SpaceRenderer({super.key, required this.container, this.requestOnInit = false});

  @override
  State<SpaceRenderer> createState() => _SpaceRendererState();
}

class _SpaceRendererState extends State<SpaceRenderer> {

  final loading = true.obs;
  SpaceInfo? info;

  @override
  void initState() {
    if(!widget.requestOnInit) return;
    super.initState();
  }

  void loadState() async {
    info = await widget.container.getInfo();
    loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Rendering of info
    return Container(
      padding: const EdgeInsets.all(defaultSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Get.theme.colorScheme.onBackground,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Space ${widget.container.roomId}", style: Get.theme.textTheme.labelLarge),
              verticalSpacing(elementSpacing),
              //renderMiniAvatars(10),
            ]
          ),
          horizontalSpacing(sectionSpacing),

          //* Join button
          FJElevatedButton(
            smallCorners: true,
            onTap: () => Get.find<SpacesController>().join(widget.container), 
            child: Text("Join the fun!", style: Get.theme.textTheme.labelMedium)
          )
        ],
      ),
    );
  }
}

Widget renderAvatars(int amount) {

  final realAmount = min(amount, 5);
  return SizedBox(
    width: sectionSpacing * (realAmount + 2),
    height: sectionSpacing * 1.5,
    child: Stack(
      children: List.generate(realAmount, (index) {
        
        final positionedWidget = index == realAmount-1 && amount > 5 ?
          Container(
            height: sectionSpacing * 1.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(sectionSpacing * 1.5),
              color: Get.theme.colorScheme.background,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: elementSpacing),
              child: Center(
                child: Text("+${amount-realAmount+1}", style: Get.theme.textTheme.labelSmall!.copyWith(color: Get.theme.colorScheme.onPrimary)),
              ),
            ),
          ) :
          SizedBox(
            width: sectionSpacing * 1.5,
            height: sectionSpacing * 1.5,
            child: CircleAvatar(
              backgroundColor: index % 2 == 0 ? Get.theme.colorScheme.errorContainer : Get.theme.colorScheme.tertiaryContainer,
              child: Icon(Icons.person, size: sectionSpacing, color: Get.theme.colorScheme.onSurface),
            ),
          );

        return Positioned(
          left: index * sectionSpacing,
          child: positionedWidget,
        );
      }),
    ),
  );
}