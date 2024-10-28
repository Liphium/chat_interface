import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/theme/ui/dialogs/message_info_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:pasteboard/pasteboard.dart';

class MessageOptionsWindow extends StatefulWidget {
  final ContextMenuData data;
  final bool self;
  final Message message;
  final List<ProfileButton>? extra;

  const MessageOptionsWindow({
    super.key,
    required this.data,
    required this.self,
    required this.message,
    this.extra,
  });

  @override
  State<MessageOptionsWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<MessageOptionsWindow> {
  final messageDeletionLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final friend = Get.find<FriendController>().friends[widget.message.senderAddress];

    return SlidingWindowBase(
      lessPadding: true,
      position: widget.data,
      maxSize: 250,
      title: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add extra context menu buttons (copy, etc. (if passed in))
          if (widget.extra != null)
            for (var button in widget.extra!)
              Padding(
                padding: const EdgeInsets.only(bottom: elementSpacing),
                child: button,
              ),
          if (widget.extra != null) verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.info,
            label: "message.info".tr,
            onTap: () {
              Get.back();
              Get.dialog(MessageInfoWindow(message: widget.message));
            },
            loading: false.obs,
          ),
          if (widget.message.type == MessageType.text && widget.message.content != "")
            Padding(
              padding: const EdgeInsets.only(top: elementSpacing),
              child: ProfileButton(
                icon: Icons.copy,
                label: "message.copy".tr,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.message.content));
                  Get.back();
                },
                loading: false.obs,
              ),
            ),
          if (widget.message.attachmentsRenderer.length == 1 && widget.message.attachmentsRenderer[0].downloaded.value)
            Padding(
              padding: const EdgeInsets.only(top: elementSpacing),
              child: ProfileButton(
                icon: Icons.cloud_download,
                label: "message.save_to".tr,
                onTap: () async {
                  // Make sure this can't be used on either mobile or web
                  if (!isDesktopPlatform()) {
                    showErrorPopup("error", "not.supported".tr);
                    return;
                  }

                  // Get the location where the file should be saved
                  final attachment = widget.message.attachmentsRenderer[0];
                  final saveLocation = await getSaveLocation(suggestedName: attachment.fileName);
                  if (saveLocation == null) {
                    return;
                  }

                  // Save the file to the desired location and go out of the menu
                  await attachment.file!.saveTo(saveLocation.path);
                  Get.back();
                },
                loading: false.obs,
              ),
            ),
          if (widget.message.attachmentsRenderer.length == 1 && widget.message.attachmentsRenderer[0].downloaded.value)
            Padding(
              padding: const EdgeInsets.only(top: elementSpacing),
              child: ProfileButton(
                icon: Icons.launch,
                label: "message.open".tr,
                onTap: () async {
                  // Make sure this can't be used on either mobile or web
                  if (!isDesktopPlatform()) {
                    showErrorPopup("error", "not.supported".tr);
                    return;
                  }

                  // Open the file with the default app
                  final attachment = widget.message.attachmentsRenderer[0];
                  OpenAppFile.open(attachment.file!.path);
                  Get.back();
                },
                loading: false.obs,
              ),
            ),
          if (widget.message.attachmentsRenderer.length == 1 && widget.message.attachmentsRenderer[0].downloaded.value && isDesktopPlatform())
            Padding(
              padding: const EdgeInsets.only(top: elementSpacing),
              child: ProfileButton(
                icon: Icons.content_copy,
                label: "message.copy_file".tr,
                onTap: () async {
                  // Copy the file to clipboard
                  await Pasteboard.writeFiles([widget.message.attachmentsRenderer[0].file!.path]);
                  Get.back();
                },
                loading: false.obs,
              ),
            ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.person,
            label: "message.profile".tr,
            onTap: () {
              Get.back();
              showModal(Profile(friend: friend ?? Friend.unknown(widget.message.senderAddress)));
            },
            loading: false.obs,
          ),
          if (widget.message.type == MessageType.text)
            Padding(
              padding: const EdgeInsets.only(top: elementSpacing),
              child: ProfileButton(
                icon: Icons.reply,
                label: "message.reply".tr,
                onTap: () {
                  MessageSendHelper.addReplyToCurrentDraft(widget.message);
                  Get.back();
                },
                loading: false.obs,
              ),
            ),
          if (widget.self)
            Padding(
              padding: const EdgeInsets.only(top: defaultSpacing),
              child: ProfileButton(
                color: Get.theme.colorScheme.onError,
                iconColor: Get.theme.colorScheme.error,
                icon: Icons.delete,
                label: "message.delete".tr,
                onTap: () async {
                  // Set and check loading state
                  if (messageDeletionLoading.value) return;
                  messageDeletionLoading.value = true;

                  // Delete message
                  final result = await widget.message.delete();
                  messageDeletionLoading.value = false;
                  if (result != null) {
                    showErrorPopup("error", result);
                    return;
                  }

                  Get.back();
                },
                loading: messageDeletionLoading,
              ),
            ),
        ],
      ),
    );
  }
}
