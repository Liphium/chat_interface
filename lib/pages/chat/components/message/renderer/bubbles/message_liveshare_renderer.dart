import 'dart:async';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/zap_share_controller.dart';
import 'package:chat_interface/theme/components/file_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BubblesLiveshareMessageRenderer extends StatefulWidget {
  final MessageProvider provider;
  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;

  const BubblesLiveshareMessageRenderer({
    super.key,
    required this.provider,
    required this.message,
    this.self = false,
    this.last = false,
    this.sender,
  });

  @override
  State<BubblesLiveshareMessageRenderer> createState() => _BubblesLiveshareMessageRendererState();
}

class _BubblesLiveshareMessageRendererState extends State<BubblesLiveshareMessageRenderer> {
  final loading = true.obs;
  final available = false.obs;
  LiveshareInviteContainer? container;
  int unavailableCount = 0;
  final size = 0.obs;
  String transactionBegin = "";

  Timer? timer;

  @override
  void initState() {
    super.initState();
    container = LiveshareInviteContainer.fromJson(widget.message.content);
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => updateInfo());
    transactionBegin = container!.id;
    updateInfo();
  }

  void updateInfo() async {
    if (transactionBegin != container!.id) {
      sendLog("WTF Flutter is actually weird $transactionBegin ${container!.id}");
      return;
    }

    final json = await postAny("${nodeProtocol()}${container!.url}/liveshare/info", {
      "id": container!.id,
      "token": container!.token,
    });
    loading.value = false;

    if (!json["success"]) {
      unavailableCount++;
      sendLog(unavailableCount);
      if (unavailableCount > 5) {
        available.value = false;
        timer?.cancel();
      }
      available.value = false;
      return;
    }

    available.value = true;
    size.value = json["size"];
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Friend sender = widget.sender ?? Friend.system();
    final controller = Get.find<ZapShareController>();
    container = LiveshareInviteContainer.fromJson(widget.message.content);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: elementSpacing,
          horizontal: sectionSpacing,
        ),
        child: Row(
          textDirection: widget.self ? TextDirection.rtl : TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            //* Avatar
            Visibility(
              visible: !widget.last,
              replacement: const SizedBox(width: 34), //* Show timestamp instead
              child: Obx(() => Tooltip(message: sender.displayName.value, child: UserAvatar(id: sender.id, size: 34))),
            ),
            horizontalSpacing(defaultSpacing),

            //* Message
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: widget.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: widget.self ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 0.5, horizontal: defaultSpacing),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            color: widget.self ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer,
                          ),
                          child: Column(
                            crossAxisAlignment: widget.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.electric_bolt, color: Get.theme.colorScheme.onPrimary),
                                  horizontalSpacing(elementSpacing),
                                  Flexible(
                                    child: Text(
                                      "chat.zapshare_request".tr,
                                      style: Get.theme.textTheme.labelLarge,
                                    ),
                                  ),
                                ],
                              ),

                              //* Mobile timestamp and verified indicator
                              if (isMobileMode())
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: elementSpacing),
                                      child: SelectionContainer.disabled(
                                        child: Text(formatMessageTime(widget.message.createdAt), style: Get.theme.textTheme.bodySmall),
                                      ),
                                    ),
                                    Obx(() {
                                      final verified = widget.message.verified.value;
                                      return Visibility(
                                        visible: !verified,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: elementSpacing),
                                          child: Tooltip(
                                            message: "chat.not.signed".tr,
                                            child: const Icon(
                                              Icons.warning_rounded,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),

                      //* Desktop timestamp
                      if (!isMobileMode()) horizontalSpacing(defaultSpacing),

                      if (!isMobileMode())
                        Padding(
                          padding: const EdgeInsets.only(top: defaultSpacing),
                          child: SelectionContainer.disabled(
                            child: Text(formatMessageTime(widget.message.createdAt), style: Get.theme.textTheme.bodySmall),
                          ),
                        ),

                      //* Desktop verified indicator
                      if (!isMobileMode()) horizontalSpacing(defaultSpacing),

                      //* Verified indicator
                      if (!isMobileMode())
                        Obx(() {
                          final verified = widget.message.verified.value;
                          return Visibility(
                            visible: !verified,
                            child: Tooltip(
                              message: "chat.not.signed".tr,
                              child: const Icon(
                                Icons.warning_rounded,
                                color: Colors.amber,
                              ),
                            ),
                          );
                        })
                    ],
                  ),
                  verticalSpacing(defaultSpacing),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      color: widget.self ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: defaultSpacing, horizontal: defaultSpacing),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getIconForFileName(container!.fileName),
                          size: sectionSpacing * 2,
                          color: Get.theme.colorScheme.onPrimary,
                        ),
                        horizontalSpacing(defaultSpacing),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  container!.fileName,
                                  style: Get.theme.textTheme.labelMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Flexible(
                                child: Obx(
                                  () => Text(
                                    available.value ? formatFileSize(size.value) : 'chat.zapshare.not_found'.tr,
                                    style: Get.theme.textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        horizontalSpacing(defaultSpacing),

                        //* Accept button
                        Obx(() {
                          // Return loading if this message wasn't send inside of a conversation
                          if (widget.provider is! ConversationMessageProvider) {
                            return SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                color: Get.theme.colorScheme.onPrimary,
                                value: controller.progress.value,
                              ),
                            );
                          }

                          final convProvider = widget.provider as ConversationMessageProvider;
                          if (available.value && controller.currentConversation.value == convProvider.conversation.id) {
                            return SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                color: Get.theme.colorScheme.onPrimary,
                                value: controller.progress.value,
                              ),
                            );
                          }

                          return Visibility(
                            visible: available.value && !widget.self,
                            child: IconButton(
                              onPressed: () => Get.find<ZapShareController>().joinTransaction(
                                convProvider.conversation.id,
                                widget.message.senderAddress,
                                container!,
                              ),
                              icon: const Icon(Icons.check),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatFileSize(int fileSize) {
  if (fileSize < 1024) {
    return "file.bytes".trParams({"count": fileSize.toString()});
  }

  if (fileSize < 1024 * 1024) {
    return "file.kilobytes".trParams({"count": (fileSize / 1024).toStringAsFixed(2)});
  }

  if (fileSize < 1024 * 1024 * 1024) {
    return "file.megabytes".trParams({"count": (fileSize / (1024 * 1024)).toStringAsFixed(2)});
  }

  return "file.gigabytes".trParams({"count": (fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)});
}
