import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/member_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationMembers extends StatelessWidget {
  final Conversation conversation;

  const ConversationMembers({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final ownRole = conversation.members[conversation.token.id]!.role;
    final controller = Get.find<MessageController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: elementSpacing, vertical: defaultSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultSpacing + elementSpacing),
                child: Obx(() =>
                    Text('chat.members'.trParams({"count": controller.selectedConversation.value.members.length.toString()}), style: Theme.of(context).textTheme.titleMedium)),
              ),
              LoadingIconButton(
                loading: conversation.membersLoading,
                onTap: () => conversation.fetchMembers(DateTime.now()),
                icon: Icons.refresh,
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: elementSpacing),
            child: Obx(
              () => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.selectedConversation.value.members.length,
                itemBuilder: (context, index) {
                  final GlobalKey listKey = GlobalKey();
                  final member = controller.selectedConversation.value.members.values.elementAt(index);
                  return Padding(
                    key: listKey,
                    padding: const EdgeInsets.only(bottom: elementSpacing),
                    child: Material(
                      color: Get.theme.colorScheme.onBackground,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        onTap: () {
                          final friend = Get.find<FriendController>().friends[member.account];
                          if (StatusController.ownAccountId != member.account) {
                            final RenderBox box = listKey.currentContext?.findRenderObject() as RenderBox;
                            Get.dialog(
                              Profile(
                                position: box.localToGlobal(box.size.bottomLeft(Offset.zero)),
                                friend: friend ?? Friend.unknown(member.account),
                                size: box.size.width.toInt(),
                                actions: (friend) {
                                  return [
                                        //* Promotion actions
                                        if (ownRole.higherOrEqual(MemberRole.moderator) && member.role == MemberRole.user)
                                          ProfileAction(
                                              icon: Icons.add_moderator, label: "chat.make_moderator".tr, loading: false.obs, onTap: (f, l) => member.promote(conversation.id))
                                        else if (ownRole == MemberRole.admin && member.role == MemberRole.moderator)
                                          ProfileAction(
                                              icon: Icons.add_moderator, label: "chat.make_admin".tr, loading: false.obs, onTap: (f, l) => member.promote(conversation.id)),

                                        //* Demotion actions
                                        if (ownRole.higherOrEqual(MemberRole.moderator) && member.role == MemberRole.moderator)
                                          ProfileAction(
                                            icon: Icons.remove_moderator,
                                            label: "chat.remove_moderator".tr,
                                            loading: false.obs,
                                            onTap: (f, l) => member.demote(conversation.id),
                                          )
                                        else if (ownRole == MemberRole.admin && member.role.higherOrEqual(MemberRole.moderator))
                                          ProfileAction(
                                            icon: Icons.remove_moderator,
                                            label: "chat.remove_admin".tr,
                                            loading: false.obs,
                                            onTap: (f, l) => member.demote(conversation.id),
                                          ),

                                        //* Removal actions
                                        if (ownRole.higherOrEqual(MemberRole.moderator) && member.role.lowerThan(ownRole))
                                          ProfileAction(
                                            icon: Icons.person_remove,
                                            label: "chat.remove_member".tr,
                                            loading: false.obs,
                                            color: Get.theme.colorScheme.errorContainer,
                                            iconColor: Get.theme.colorScheme.error,
                                            onTap: (f, l) => member.remove(conversation.id),
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
                              Expanded(child: UserRenderer(id: member.account)),
                              horizontalSpacing(elementSpacing),
                              if (member.role != MemberRole.user)
                                Padding(
                                  padding: const EdgeInsets.only(left: defaultSpacing),
                                  child: Tooltip(
                                    message: member.role == MemberRole.admin ? "chat.admin".tr : "chat.moderator".tr,
                                    child: Icon(
                                      Icons.shield,
                                      color: member.role == MemberRole.admin ? Get.theme.colorScheme.error : Get.theme.colorScheme.onPrimary,
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
    );
  }
}
