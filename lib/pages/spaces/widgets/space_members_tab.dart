import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/town/tabletop_settings.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SpaceMembersTab extends StatefulWidget {
  const SpaceMembersTab({super.key});

  @override
  State<SpaceMembersTab> createState() => _SpaceMembersTabState();
}

class _SpaceMembersTabState extends State<SpaceMembersTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: elementSpacing, vertical: defaultSpacing),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: elementSpacing),
        child: Watch(
          (context) => ListView.builder(
            shrinkWrap: true,
            itemCount: SpaceMemberController.members.length,
            itemBuilder: (context, index) {
              final GlobalKey listKey = GlobalKey();
              final member = SpaceMemberController.members.values.elementAt(index);

              return Padding(
                key: listKey,
                padding: const EdgeInsets.only(bottom: elementSpacing),
                child: Material(
                  color: Get.theme.colorScheme.onInverseSurface,
                  child: InkWell(
                    onTap: () {
                      if (StatusController.ownAddress != member.friend.id) {
                        final RenderBox box = listKey.currentContext?.findRenderObject() as RenderBox;
                        Get.dialog(
                          Profile(
                            data: ContextMenuData.fromKey(listKey, below: true),
                            friend: member.friend,
                            size: box.size.width.toInt(),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    child: Padding(
                      padding: const EdgeInsets.all(elementSpacing),
                      child: Row(
                        children: [
                          Flexible(child: UserRenderer(id: member.friend.id)),
                          horizontalSpacing(defaultSpacing),
                          Watch(
                            (context) => Visibility(
                              visible: !member.verified.value,
                              child: Padding(
                                padding: const EdgeInsets.only(right: defaultSpacing),
                                child: Tooltip(
                                  message: "spaces.member.not_verified".tr,
                                  child: Icon(Icons.warning, color: Get.theme.colorScheme.secondaryContainer),
                                ),
                              ),
                            ),
                          ),
                          Watch((context) {
                            var hue = TabletopController.cursors[member.id]?.hue;

                            // Don't render a color in case there isn't one
                            if (hue == null && StatusController.ownAddress != member.friend.id) {
                              return SizedBox();
                            }

                            // Calculate color in case not there
                            Color? color;
                            if (StatusController.ownAddress == member.friend.id) {
                              color = TabletopSettings.getCursorColor();
                            } else {
                              color = TabletopSettings.getCursorColor(hue: hue!.value);
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(sectionSpacing),
                              ),
                              width: sectionSpacing,
                              height: sectionSpacing,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
