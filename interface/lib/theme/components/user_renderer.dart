import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserAvatar extends StatelessWidget {

  final String id;
  final double? size;
  final FriendController? controller;
  final Friend? user;

  const UserAvatar({super.key, required this.id, this.size, this.controller, this.user});

  @override
  Widget build(BuildContext context) {

    var friend = (user ?? (controller ?? Get.find<FriendController>()).friends[id]);
    if(id == ownAccountId) friend = Friend.me();

    return SizedBox(
      width: size ?? 45,
      height: size ?? 45,
      child: CircleAvatar(
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        radius: size ?? 45,
        child: Text(
          friend != null ? friend.name.substring(0,1) : id.substring(0, 1), 
          style: Get.theme.textTheme.labelMedium!.copyWith(
            fontSize: (size ?? 45) * 0.5,
            fontWeight: FontWeight.bold,
            color: id == ownAccountId ? Get.theme.colorScheme.tertiary : Get.theme.colorScheme.onPrimary
          )
        ),
      ),
    );
  }
}

class UserRenderer extends StatelessWidget {

  final String id;
  final FriendController? controller;

  const UserRenderer({super.key, required this.id, this.controller});

  @override
  Widget build(BuildContext context) {

    var friend = (controller ?? Get.find<FriendController>()).friends[id];
    final own = id == ownAccountId;
    StatusController? statusController = own ? Get.find<StatusController>() : null;
    if(own) friend = Friend.me(statusController);
    friend ??= Friend.unknown(id);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(id: friend.id, size: 40),
        horizontalSpacing(defaultSpacing),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(friend.name, overflow: TextOverflow.ellipsis, style: Get.theme.textTheme.bodyMedium),
                  horizontalSpacing(defaultSpacing),
                  Obx(() =>
                    StatusRenderer(status: own ? statusController!.type.value : friend!.statusType.value)
                  ),
                ],
              ),
              Obx(() =>
                Visibility(
                  visible: own ? statusController!.status.value != "-" : friend!.status.value != "-",
                  child: Text(own ? statusController!.status.value : friend!.status.value, style: Get.theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis,)
                )
              )
            ],
          ),
        )
      ],
    );
  }
}