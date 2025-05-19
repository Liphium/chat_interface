import 'dart:async';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/zap_share_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/theme/components/file_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/message_options_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class BubblesLiveshareMessageRenderer extends StatefulWidget {
  final MessageProvider provider;
  final Message message;
  final bool self;
  final Friend? sender;
  final bool mobileLayout;

  const BubblesLiveshareMessageRenderer({
    super.key,
    required this.provider,
    required this.message,
    this.self = false,
    this.sender,
    this.mobileLayout = false,
  });

  @override
  State<BubblesLiveshareMessageRenderer> createState() => _BubblesLiveshareMessageRendererState();
}

class _BubblesLiveshareMessageRendererState extends State<BubblesLiveshareMessageRenderer> {
  final _loading = signal(true);
  final _available = signal(false);
  LiveshareInviteContainer? _container;
  int _unavailableCount = 0;
  final _size = signal(0);
  String _transactionBegin = "";

  Timer? _timer;

  // For the context menu
  double _mouseX = 0, _mouseY = 0;

  @override
  void initState() {
    super.initState();
    _container = LiveshareInviteContainer.fromJson(widget.message.content);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => updateInfo());
    _transactionBegin = _container!.id;
    updateInfo();
  }

  Future<void> updateInfo() async {
    if (_transactionBegin != _container!.id) {
      sendLog("WTF Flutter is actually weird $_transactionBegin ${_container!.id}");
      return;
    }

    final json = await postAny("${nodeProtocol()}${_container!.url}/liveshare/info", {
      "id": _container!.id,
      "token": _container!.token,
    });
    _loading.value = false;

    if (!json["success"]) {
      _unavailableCount++;
      sendLog(_unavailableCount);
      if (_unavailableCount > 5) {
        _available.value = false;
        _timer?.cancel();
      }
      _available.value = false;
      return;
    }

    _available.value = true;
    _size.value = json["size"];
  }

  @override
  void dispose() {
    _loading.dispose();
    _available.dispose();
    _size.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Friend sender = widget.sender ?? Friend.system();
    _container = LiveshareInviteContainer.fromJson(widget.message.content);

    return RepaintBoundary(
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.translucent,
        // This tracks the mouse for where the context menu should be
        onHover: (event) {
          _mouseX = event.position.dx;
          _mouseY = event.position.dy;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,

          // Open the context menu when right-clicking on the message
          onSecondaryTap: () {
            final menuData = ContextMenuData.fromPosition(Offset(_mouseX, _mouseY));

            // Open the context menu
            Get.dialog(
              MessageOptionsWindow(
                data: menuData,
                self: widget.message.senderAddress == StatusController.ownAddress,
                message: widget.message,
                provider: widget.provider,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: elementSpacing),
            child: Row(
              textDirection: widget.self ? TextDirection.rtl : TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar of the message sender
                Tooltip(
                  message: sender.displayName.value,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () => showModal(Profile(friend: sender)),
                    child: UserAvatar(id: sender.id, size: 34),
                  ),
                ),
                horizontalSpacing(defaultSpacing),

                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: widget.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        textDirection: widget.self ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(defaultSpacing),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(defaultSpacing),
                                color:
                                    widget.self
                                        ? Get.theme.colorScheme.primary
                                        : Get.theme.colorScheme.primaryContainer,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.electric_bolt, color: Get.theme.colorScheme.onPrimary),
                                      horizontalSpacing(elementSpacing),
                                      Flexible(
                                        child: Text("chat.zapshare_request".tr, style: Get.theme.textTheme.labelLarge),
                                      ),
                                    ],
                                  ),

                                  // The file that Zap is currently sharing
                                  verticalSpacing(defaultSpacing),
                                  renderZapEmbed(),
                                ],
                              ),
                            ),
                          ),

                          // Show a timestamp straight after the message
                          horizontalSpacing(defaultSpacing),
                          Padding(
                            padding: const EdgeInsets.only(top: defaultSpacing),
                            child: SelectionContainer.disabled(
                              child: Text(
                                formatMessageTime(widget.message.createdAt),
                                style: Get.theme.textTheme.bodySmall,
                              ),
                            ),
                          ),

                          // Show a warning in case the message couldn't be verified
                          horizontalSpacing(defaultSpacing),
                          Watch((ctx) {
                            final verified = widget.message.verified.value;
                            return Visibility(
                              visible: !verified,
                              child: Padding(
                                padding: const EdgeInsets.only(top: elementSpacing + elementSpacing / 4),
                                child: Tooltip(
                                  message: "chat.not.signed".tr,
                                  child: const Icon(Icons.warning_rounded, color: Colors.amber),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget renderZapEmbed() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultSpacing),
        color: widget.self ? Get.theme.colorScheme.onPrimary.withAlpha(40) : Get.theme.colorScheme.inverseSurface,
      ),
      padding: const EdgeInsets.symmetric(vertical: defaultSpacing, horizontal: defaultSpacing),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getIconForFileName(_container!.fileName),
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
                    _container!.fileName,
                    style: Get.theme.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Watch(
                    (ctx) => Text(
                      _available.value ? formatFileSize(_size.value) : 'chat.zapshare.not_found'.tr,
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
          Watch((ctx) {
            // Return loading if this message wasn't send inside of a conversation
            if (widget.provider is! ConversationMessageProvider) {
              return SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary),
              );
            }

            final convProvider = widget.provider as ConversationMessageProvider;
            if (_available.value && ZapShareController.currentConversation.value == convProvider.conversation.id) {
              return SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Get.theme.colorScheme.onPrimary,
                  value: ZapShareController.progress.value,
                ),
              );
            }

            return Visibility(
              visible: _available.value && !widget.self,
              child: IconButton(
                onPressed:
                    () => ZapShareController.joinTransaction(
                      convProvider.conversation.id,
                      widget.message.senderAddress,
                      _container!,
                    ),
                icon: const Icon(Icons.check),
              ),
            );
          }),
        ],
      ),
    );
  }
}

String formatFileSize(int fileSize) {
  if (fileSize <= 0) {
    return "file.unknown_size".tr;
  }

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
