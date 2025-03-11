import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserAvatar extends StatefulWidget {
  final LPHAddress id;
  final double? size;
  final Friend? user;

  const UserAvatar({super.key, required this.id, this.size, this.user});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  @override
  void initState() {
    var friend = getFriend();
    friend.loadProfilePicture();
    super.initState();
  }

  Friend getFriend() {
    if (widget.user != null) {
      return widget.user!;
    }
    return FriendController.friends[widget.id] ?? Friend.unknown(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    var friend = getFriend();

    return SizedBox(
      width: widget.size ?? 45,
      height: widget.size ?? 45,
      child: Obx(
        () {
          if (friend.profilePictureImage.value != null) {
            final image = friend.profilePictureImage.value!;
            return ClipOval(
              child: RawImage(
                fit: BoxFit.contain,
                image: image,
              ),
            );
          }

          final cuttedDisplayName = friend.displayName.value.substring(0, 1);
          return ClipOval(
            child: Container(
              color: Get.theme.colorScheme.primaryContainer,
              child: SelectionContainer.disabled(
                child: Center(
                  child: Text(
                    cuttedDisplayName,
                    style: Get.theme.textTheme.labelMedium!.copyWith(
                      fontSize: (widget.size ?? 45) * 0.5,
                      fontWeight: FontWeight.bold,
                      color: widget.id == StatusController.ownAddress ? Get.theme.colorScheme.tertiary : Get.theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserRenderer extends StatelessWidget {
  final LPHAddress id;
  final FriendController? controller;

  const UserRenderer({super.key, required this.id, this.controller});

  @override
  Widget build(BuildContext context) {
    var friend = FriendController.friends[id];
    final own = id == StatusController.ownAddress;
    StatusController? statusController = own ? Get.find<StatusController>() : null;
    if (own) friend = Friend.me(statusController);
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
                  Flexible(child: Text(friend.displayName.value, overflow: TextOverflow.ellipsis, style: Get.theme.textTheme.bodyMedium)),
                  if (friend.id.server != basePath)
                    Padding(
                      padding: const EdgeInsets.only(left: defaultSpacing),
                      child: Tooltip(
                        waitDuration: const Duration(milliseconds: 500),
                        message: "friends.different_town".trParams({
                          "town": friend.id.server,
                        }),
                        child: Icon(
                          Icons.sensors,
                          color: Get.theme.colorScheme.onPrimary,
                          size: 21,
                        ),
                      ),
                    ),
                  horizontalSpacing(defaultSpacing),
                  Obx(() => StatusRenderer(status: own ? StatusController.type.value : friend!.statusType.value)),
                ],
              ),
              Obx(
                () => Visibility(
                  visible: own ? StatusController.status.value != "" : friend!.status.value != "",
                  child: Text(
                    own ? StatusController.status.value : friend!.status.value,
                    style: Get.theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
