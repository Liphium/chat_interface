import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/square/shared_space_controller.dart';
import 'package:chat_interface/pages/chat/components/squares/shared_space_add_window.dart';
import 'package:chat_interface/services/squares/square_shared_space.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SquareSharedSpaces extends StatefulWidget {
  final Conversation conversation;

  const SquareSharedSpaces({super.key, required this.conversation});

  @override
  State<SquareSharedSpaces> createState() => _SquareSharedSpacesState();
}

class _SquareSharedSpacesState extends State<SquareSharedSpaces> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Render dynamic shared spaces
        Watch((ctx) {
          // Only render when there actually are dynamically shared spaces
          final sharedSpaces = SharedSpaceController.sharedSpaceMap[widget.conversation.id];
          if (sharedSpaces == null) {
            return SizedBox();
          }
          final spaces = sharedSpaces.entries.where((entry) => entry.key.startsWith("space")).toList();

          // Render the dynamically shared space as an item
          return ListView.builder(
            shrinkWrap: true,
            itemCount: spaces.length,
            itemBuilder: (context, index) {
              final space = spaces[index].value;
              return Padding(padding: const EdgeInsets.only(bottom: defaultSpacing), child: renderSpaceItem(space));
            },
          );
        }),

        // Create a button for creating shared spaces
        Watch(
          (ctx) => Visibility(
            visible: SpaceController.connected.value,
            child: Padding(
              padding: const EdgeInsets.only(right: defaultSpacing, left: defaultSpacing, bottom: defaultSpacing),
              child: FJElevatedButton(
                onTap: () => showModal(SharedSpaceAddWindow(square: widget.conversation as Square, action: "add")),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.launch, color: Get.theme.colorScheme.onPrimary),
                    horizontalSpacing(defaultSpacing),
                    Text("squares.spaces.add".tr, style: Get.theme.textTheme.labelMedium),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Create a button for creating shared spaces
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
          child: FJElevatedButton(
            onTap: () => showModal(SharedSpaceAddWindow(square: widget.conversation as Square)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch, color: Get.theme.colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Text("squares.spaces.create".tr, style: Get.theme.textTheme.labelMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Render a shared space
  Widget renderSpaceItem(SharedSpace space) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(sectionSpacing),
        ),
        padding: EdgeInsets.only(
          top: sectionSpacing * 0.75,
          bottom: sectionSpacing,
          right: sectionSpacing,
          left: sectionSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(space.name, style: Get.textTheme.labelMedium),
            verticalSpacing(defaultSpacing),
            for (var member in space.members)
              Builder(
                builder: (context) {
                  final friend = FriendController.getFriend(LPHAddress.from(member));
                  return Padding(
                    padding: const EdgeInsets.only(top: defaultSpacing),
                    child: Row(
                      children: [
                        UserAvatar(id: friend.id, size: 28),
                        horizontalSpacing(defaultSpacing),
                        // Not watching here, should be fine (hover = update)
                        Text(friend.displayName.peek(), style: Get.textTheme.bodyMedium),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
