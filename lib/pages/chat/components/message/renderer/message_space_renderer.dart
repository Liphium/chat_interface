import 'dart:convert';
import 'dart:math';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpaceMessageRenderer extends StatefulWidget {

  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;

  const SpaceMessageRenderer({super.key, required this.message, this.self = false, this.last = false, this.sender});

  @override
  State<SpaceMessageRenderer> createState() => _CallMessageRendererState();
}

class _CallMessageRendererState extends State<SpaceMessageRenderer> {

  final loading = false.obs;

  @override
  Widget build(BuildContext context) {

    Friend sender = widget.sender ?? Friend.system();
    ThemeData theme = Theme.of(context);
    final container = SpaceConnectionContainer.fromJson(jsonDecode(widget.message.content));

    return Padding(
      padding: const EdgeInsets.only(top: defaultSpacing),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        splashColor: theme.hoverColor,
        onTap: () => {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: elementSpacing,
            horizontal: sectionSpacing,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //* Icon
              SizedBox(
                width: 50,
                child: Center(child: Icon(Icons.speaker_group, size: 30, color: theme.colorScheme.onPrimary)),
              ),
              horizontalSpacing(sectionSpacing),

              //* Space info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(sender.name, style: theme.textTheme.labelLarge),
                        Text(" invited you to a space.", style: theme.textTheme.bodyLarge),
                      ],
                    ),

                    verticalSpacing(defaultSpacing * 0.5),
                    
                    //* Space embed
                    Container(
                      padding: const EdgeInsets.all(defaultSpacing),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.colorScheme.onBackground,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Space ${container.roomId}", style: theme.textTheme.labelLarge),
                              verticalSpacing(elementSpacing),
                              renderMiniAvatars(10),
                            ]
                          ),
                          horizontalSpacing(sectionSpacing),

                          //* Join button
                          FJElevatedButton(
                            smallCorners: true,
                            onTap: () => {}, 
                            child: Text("Join the fun!", style: theme.textTheme.labelMedium)
                          )
                        ],
                      ),
                    )
                  ],
                )
              ),

              horizontalSpacing(defaultSpacing),

              Visibility(
                visible: !widget.message.verified,
                child: Tooltip(
                  message: "not.signed".tr,
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.amber,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget renderMiniAvatars(int amount) {

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