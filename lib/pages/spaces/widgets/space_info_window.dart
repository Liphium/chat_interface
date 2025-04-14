import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/spaces/studio/studio_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/theme/components/forms/fj_switch.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SpaceInfoWindow extends StatelessWidget {
  const SpaceInfoWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Space on ${SpaceController.domain!}", style: Get.theme.textTheme.titleMedium),
          verticalSpacing(defaultSpacing),
          ProfileButton(
            icon: Icons.content_copy,
            label: "Copy Space ID",
            onTap: () => Clipboard.setData(ClipboardData(text: SpaceController.id.value!)),
          ),
          verticalSpacing(defaultSpacing),
          Row(
            children: [
              Text("Disable Tabletop cursors"),
              const Spacer(),
              Watch(
                (context) => FJSwitch(
                  value: TabletopController.disableCursorSending.value,
                  onChanged: (b) => TabletopController.disableCursorSending.value = b,
                ),
              ),
            ],
          ),
          verticalSpacing(sectionSpacing),
          Text("Studio (experimental)", style: Get.theme.textTheme.labelMedium),
          verticalSpacing(defaultSpacing),
          ProfileButton(
            icon: Icons.launch,
            label: "Connect to Studio",
            onTap: () {
              StudioController.connectToStudio();
              Get.back();
            },
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.play_arrow,
            label: "Try video track",
            onTap: () {
              StudioController.getConnection()!.getPublisher().createCameraTrack();
            },
          ),
          verticalSpacing(sectionSpacing),
          Text("Members", style: Get.theme.textTheme.labelMedium),
          verticalSpacing(defaultSpacing),
          Watch((context) {
            return Column(
              children:
                  SpaceMemberController.members.value.values.map((member) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: elementSpacing),
                      child: Row(
                        children: [
                          Text(
                            member.friend.displayName.value,
                            style: Get.theme.textTheme.bodyMedium,
                          ),
                          horizontalSpacing(defaultSpacing),
                          Text("#${member.id}", style: Get.theme.textTheme.bodyMedium),
                        ],
                      ),
                    );
                  }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
