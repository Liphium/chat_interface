import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/pages/spaces/widgets/space_grid_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class SpaceMemberTab extends StatefulWidget {
  const SpaceMemberTab({super.key});

  @override
  State<SpaceMemberTab> createState() => _SpaceMemberTabState();
}

class _SpaceMemberTabState extends State<SpaceMemberTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Watch((ctx) {
        return SpaceGridRenderer(
          amount: SpaceMemberController.members.value.length,
          padding: sectionSpacing,
          renderer: (index) {
            final member = SpaceMemberController.members.values.elementAt(index);

            // Render the actual user
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.onInverseSurface,
                borderRadius: BorderRadius.circular(sectionSpacing),
              ),
              child: Center(
                child: UserAvatar(
                  id: member.friend.id,
                  size: 64,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
