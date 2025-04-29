import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/square/shared_space_controller.dart';
import 'package:chat_interface/pages/chat/components/squares/shared_space_add_window.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/services/squares/square_service.dart';
import 'package:chat_interface/services/squares/square_shared_space.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/dispose_hook.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SquareSharedSpaces extends StatefulWidget {
  final Square square;

  const SquareSharedSpaces({super.key, required this.square});

  @override
  State<SquareSharedSpaces> createState() => _SquareSharedSpacesState();
}

class _SquareSharedSpacesState extends State<SquareSharedSpaces> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Render the pinned shared spaces
        Watch((ctx) {
          final container = widget.square.containerSub.value as SquareContainer;

          // Render a reordable list so the pinned spaces can be dragged around
          return ReorderableListView.builder(
            dragStartBehavior: DragStartBehavior.start,
            buildDefaultDragHandles: false,
            shrinkWrap: true,
            onReorder: (oldIndex, newIndex) async {
              // Create a new container with the order changed
              final copied = SquareContainer.copy(container);

              // Add at the new index
              final removed = container.spaces.removeAt(oldIndex);
              container.spaces.insert(oldIndex > newIndex ? newIndex : newIndex - 1, removed);

              // Change on the server, reset in case didn't work
              final error = await SquareService.refreshContainer(widget.square, copied);
              if (error != null) {
                widget.square.containerSub.value = widget.square.container;
                showErrorPopup("error", error);
              } else {
                widget.square.containerSub.value = container;
              }
            },
            itemCount: container.spaces.length,
            itemBuilder: (context, index) {
              final pinnedSpace = container.spaces[index];

              return Padding(
                key: ValueKey("psl-${pinnedSpace.id}"),
                padding: const EdgeInsets.only(bottom: defaultSpacing),
                child: ReorderableDelayedDragStartListener(
                  index: index,
                  child: Watch((ctx) {
                    final space =
                        SharedSpaceController.sharedSpaceMap[widget.square.id]?.entries
                            .firstWhereOrNull((entry) => entry.value.underlyingId == pinnedSpace.id)
                            ?.value;

                    // Create the onTap function for the item
                    Future<void> onTap() async {
                      if (pinnedSpace.loading) {
                        return;
                      }
                      pinnedSpace.loading = true;
                      final error = await SquareService.createSharedSpace(
                        widget.square,
                        pinnedSpace.name,
                        underlyingId: pinnedSpace.id,
                        rejoin: true,
                      );
                      pinnedSpace.loading = false;
                      if (error != null) {
                        showErrorPopup("error", error);
                      }
                    }

                    // Render the pinned space as empty when there isn't a shared one
                    if (space == null) {
                      return renderSpaceItem(pinnedSpace.name, [], onTap: onTap, pinnedSpace: pinnedSpace);
                    }

                    // Render the space as shared when it's actually there
                    return renderSpaceItem(
                      pinnedSpace.name,
                      space.members,
                      onTap: onTap,
                      pinnedSpace: pinnedSpace,
                      space: space,
                    );
                  }),
                ),
              );
            },
          );
        }),

        // Render dynamic shared spaces
        Watch((ctx) {
          // Only render when there actually are dynamically shared spaces
          final sharedSpaces = SharedSpaceController.sharedSpaceMap[widget.square.id];
          if (sharedSpaces == null) {
            return SizedBox();
          }
          final spaces = sharedSpaces.entries.where((entry) => entry.value.underlyingId == "-").toList();

          // Render the dynamically shared space as an item
          return ListView.builder(
            shrinkWrap: true,
            itemCount: spaces.length,
            itemBuilder: (context, index) {
              final space = spaces[index].value;
              return Padding(
                key: ValueKey("ssl-${space.id}"),
                padding: const EdgeInsets.only(bottom: defaultSpacing),
                child: SignalHook(
                  value: false,
                  builder:
                      (loading) => renderSpaceItem(
                        space.name,
                        space.members,

                        // Join the space when the item is clicked
                        onTap: () async {
                          if (loading.value) {
                            return;
                          }
                          loading.value = true;

                          // Make sure we're not connecting to the same space
                          if (SpaceController.id.peek() == space.container.roomId) {
                            loading.value = false;
                            return;
                          }

                          // Leave the space in case currently in one
                          if (SpaceController.connected.peek()) {
                            await SpaceController.leaveSpace();
                          }

                          // Connect to the new one
                          SpaceController.shouldSwitchToPage = false;
                          await SpaceController.join(space.container);
                          loading.value = false;
                        },
                        space: space,
                      ),
                ),
              );
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
                onTap: () => showModal(SharedSpaceAddWindow(square: widget.square, action: "add")),
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
            onTap: () => showModal(SharedSpaceAddWindow(square: widget.square)),
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
  Widget renderSpaceItem(
    String name,
    List<String> members, {
    SharedSpace? space,
    PinnedSharedSpace? pinnedSpace,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
      child: SignalHook(
        value: false,
        builder:
            (hovered) => Material(
              color: Get.theme.colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(sectionSpacing),
              child: InkWell(
                borderRadius: BorderRadius.circular(sectionSpacing),
                onTap: onTap,
                onHover: (value) {
                  hovered.value = value;
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  padding: EdgeInsets.all(defaultSpacing),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: elementSpacing),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              verticalSpacing(elementSpacing),
                              // Display name and icon
                              Row(
                                children: [
                                  Icon(
                                    pinnedSpace != null ? Icons.volume_up : Icons.rocket_launch,
                                    size: Get.textTheme.labelMedium!.fontSize! * 1.5,
                                  ),
                                  horizontalSpacing(defaultSpacing),
                                  Flexible(
                                    child: Text(name, overflow: TextOverflow.ellipsis, style: Get.textTheme.labelLarge),
                                  ),
                                ],
                              ),

                              // Render all of the members
                              for (var member in members)
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
                                          Flexible(
                                            child: Text(friend.displayName.peek(), style: Get.textTheme.bodyMedium),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              verticalSpacing(elementSpacing),
                            ],
                          ),
                        ),
                      ),
                      horizontalSpacing(defaultSpacing),
                      Visibility(
                        visible: hovered.value,
                        child: LoadingIconButton(
                          onTap: () {
                            showModal(
                              SharedSpaceAddWindow(
                                square: widget.square,
                                action: "edit",
                                onlyEdit: true,
                                pinned: pinnedSpace,
                                space: space,
                              ),
                            );
                          },
                          icon: Icons.edit,
                          iconSize: Get.textTheme.labelMedium!.fontSize! * 1.5,
                          extra: elementSpacing2 - 1,
                          padding: elementSpacing2 - 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
