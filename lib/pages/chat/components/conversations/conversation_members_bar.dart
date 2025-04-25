import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/services/chat/conversation_member.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

/// Right sidebar implementation
class ConversationMembersRightSidebar extends RightSidebar {
  final Conversation conversation;
  ConversationMembersRightSidebar(this.conversation) : super("conv-members");

  @override
  Widget build(BuildContext context) {
    return ConversationMembers(conversation: conversation);
  }
}

/// The actual widget behind it
class ConversationMembers extends StatelessWidget {
  final Conversation conversation;

  const ConversationMembers({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final ownRole = conversation.members[conversation.token.id]!.role;

    return Container(
      color: Get.theme.colorScheme.onInverseSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: elementSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            renderSpacePreview(),
            verticalSpacing(defaultSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
              child: FJElevatedButton(
                onTap: () => {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public, color: Get.theme.colorScheme.onPrimary),
                    horizontalSpacing(defaultSpacing),
                    Text("Create new Space", style: Get.theme.textTheme.labelMedium),
                  ],
                ),
              ),
            ),
            verticalSpacing(defaultSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultSpacing + elementSpacing),
                  child: Watch(
                    (ctx) => Text(
                      'chat.members'.trParams({"count": conversation.members.length.toString()}),
                      style: Get.theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                LoadingIconButton(
                  loading: conversation.membersLoading,
                  onTap: () => ConversationService.fetchNewestVersion(conversation),
                  icon: Icons.refresh,
                ),
              ],
            ),
            verticalSpacing(defaultSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: elementSpacing),
              child: Watch(
                (ctx) => ListView.builder(
                  shrinkWrap: true,
                  itemCount: conversation.members.length,
                  itemBuilder: (context, index) {
                    final GlobalKey listKey = GlobalKey();
                    final member = conversation.members.values.elementAt(index);
                    return Padding(
                      key: listKey,
                      padding: const EdgeInsets.only(bottom: elementSpacing),
                      child: Material(
                        color: Get.theme.colorScheme.onInverseSurface,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(defaultSpacing),
                          onTap: () {
                            final friend = FriendController.friends[member.address];
                            if (StatusController.ownAddress != member.address) {
                              final RenderBox box = listKey.currentContext?.findRenderObject() as RenderBox;
                              Get.dialog(
                                Profile(
                                  position: box.localToGlobal(box.size.bottomLeft(Offset.zero)),
                                  friend: friend ?? Friend.unknown(member.address),
                                  size: box.size.width.toInt(),
                                  actions: (friend) {
                                    return [
                                          //* Promotion actions
                                          if (ownRole.higherOrEqual(MemberRole.moderator) &&
                                              member.role == MemberRole.user)
                                            ProfileAction(
                                              icon: Icons.add_moderator,
                                              label: "chat.make_moderator".tr,
                                              onTap: (f, loading) async {
                                                loading.value = true;
                                                final error = await member.promote(conversation);
                                                if (error != null) {
                                                  showErrorPopup("error", error);
                                                } else {
                                                  Get.back();
                                                }
                                                loading.value = false;
                                              },
                                            )
                                          else if (ownRole == MemberRole.admin && member.role == MemberRole.moderator)
                                            ProfileAction(
                                              icon: Icons.add_moderator,
                                              label: "chat.make_admin".tr,
                                              onTap: (f, loading) async {
                                                loading.value = true;
                                                final error = await member.promote(conversation);
                                                if (error != null) {
                                                  showErrorPopup("error", error);
                                                } else {
                                                  Get.back();
                                                }
                                                loading.value = false;
                                              },
                                            ),

                                          //* Demotion actions
                                          if (ownRole.higherOrEqual(MemberRole.moderator) &&
                                              member.role == MemberRole.moderator)
                                            ProfileAction(
                                              icon: Icons.remove_moderator,
                                              label: "chat.remove_moderator".tr,
                                              onTap: (f, loading) async {
                                                loading.value = true;
                                                final error = await member.demote(conversation);
                                                if (error != null) {
                                                  showErrorPopup("error", error);
                                                } else {
                                                  Get.back();
                                                }
                                                loading.value = false;
                                              },
                                            )
                                          else if (ownRole == MemberRole.admin &&
                                              member.role.higherOrEqual(MemberRole.moderator))
                                            ProfileAction(
                                              icon: Icons.remove_moderator,
                                              label: "chat.remove_admin".tr,
                                              onTap: (f, loading) async {
                                                loading.value = true;
                                                final error = await member.demote(conversation);
                                                if (error != null) {
                                                  showErrorPopup("error", error);
                                                } else {
                                                  Get.back();
                                                }
                                                loading.value = false;
                                              },
                                            ),

                                          //* Removal actions
                                          if (ownRole.higherOrEqual(MemberRole.moderator) &&
                                              member.role.lowerThan(ownRole))
                                            ProfileAction(
                                              icon: Icons.person_remove,
                                              label: "chat.remove_member".tr,
                                              color: Get.theme.colorScheme.errorContainer,
                                              iconColor: Get.theme.colorScheme.error,
                                              onTap: (f, loading) async {
                                                loading.value = true;
                                                final error = await member.remove(conversation);
                                                if (error != null) {
                                                  showErrorPopup("error", error);
                                                } else {
                                                  Get.back();
                                                }
                                                loading.value = false;
                                              },
                                            ),
                                        ] +
                                        ProfileDefaults.buildDefaultActions(friend);
                                  },
                                ),
                              );
                            }
                            return;
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(elementSpacing),
                            child: Row(
                              children: [
                                Expanded(child: UserRenderer(id: member.address)),
                                horizontalSpacing(elementSpacing),
                                if (member.role != MemberRole.user)
                                  Padding(
                                    padding: const EdgeInsets.only(left: defaultSpacing),
                                    child: Tooltip(
                                      message: member.role == MemberRole.admin ? "chat.admin".tr : "chat.moderator".tr,
                                      child: Icon(
                                        Icons.shield,
                                        color:
                                            member.role == MemberRole.admin
                                                ? Get.theme.colorScheme.error
                                                : Get.theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
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
          ],
        ),
      ),
    );
  }

  Widget renderSpacePreview() {
    return Watch((ctx) {
      if (SpaceController.connected.value) {
        return SizedBox();
      }

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
              Text("Some space #1", style: Get.textTheme.labelMedium),
              verticalSpacing(sectionSpacing),
              Row(
                children: [
                  UserAvatar(id: StatusController.ownAddress, size: 28),
                  horizontalSpacing(defaultSpacing),
                  Text("Unbreathable"),
                ],
              ),
              verticalSpacing(defaultSpacing),
              Row(
                children: [
                  UserAvatar(id: StatusController.ownAddress, size: 28),
                  horizontalSpacing(defaultSpacing),
                  Text("Unbreathable"),
                ],
              ),
              verticalSpacing(defaultSpacing),
              Row(
                children: [
                  UserAvatar(id: StatusController.ownAddress, size: 28),
                  horizontalSpacing(defaultSpacing),
                  Text("Unbreathable"),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
