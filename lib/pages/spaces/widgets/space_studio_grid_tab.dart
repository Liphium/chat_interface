import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/pages/spaces/widgets/space_grid_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class SpaceStudioGridTab extends StatefulWidget {
  const SpaceStudioGridTab({super.key});

  @override
  State<SpaceStudioGridTab> createState() => _SpaceStudioGridTabState();
}

class _SpaceStudioGridTabState extends State<SpaceStudioGridTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Watch((ctx) {
        return SpaceGridRenderer(
          amount: SpaceMemberController.members.value.length,
          padding: sectionSpacing,
          renderer: (index) {
            final member = SpaceMemberController.members.values.elementAt(0);

            // Render the actual user
            return renderMember(member, theme);
          },
        );
      }),
    );
  }

  /// Render a member of the space
  Widget renderMember(SpaceMember member, ThemeData theme) {
    return Watch((context) {
      // Compute the border of the container from the talking state of the member
      Border? border;
      if (member.talking.value) {
        border = Border.all(color: theme.colorScheme.onPrimary, width: 2.0);
      }

      return Stack(
        children: [
          // Base background layer with the profile picture
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.onInverseSurface,
              border: border,
              borderRadius: BorderRadius.circular(sectionSpacing),
            ),
            child: Center(
              child: UserAvatar(
                id: member.friend.id,
                size: 64,
              ),
            ),
          ),

          // Mute/deafen/connection indicator
          Watch((ctx) {
            // Determine the icon
            IconData? icon;
            if (member.isMuted.value) {
              icon = Icons.mic_off;
            }
            if (member.isDeafened.value) {
              icon = Icons.headset_off;
            }
            if (!member.connectedToStudio.value) {
              icon = Icons.power_off;
            }

            // Render nothing if there is no icon
            if (icon == null) {
              return SizedBox();
            }

            return Positioned(
              right: defaultSpacing,
              bottom: defaultSpacing,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(200),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primaryContainer,
                      blurRadius: 10,
                    ),
                  ],
                ),
                width: 32,
                height: 32,
                child: Center(
                  child: Icon(
                    icon,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}
