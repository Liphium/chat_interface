import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/pages/chat/components/library/library_favorite_button.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/audio_attachment_player.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_zap_renderer.dart';
import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/theme/components/file_renderer.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/image_preview_window.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:signals/signals_flutter.dart';

class AttachmentRenderer extends StatefulWidget {
  final Message? message;
  final bool self;
  final ConversationMessageProvider? provider;
  final AttachmentContainer container;

  const AttachmentRenderer({super.key, required this.container, required this.self, this.message, this.provider});

  @override
  State<AttachmentRenderer> createState() => _AttachmentRendererState();
}

class _AttachmentRendererState extends State<AttachmentRenderer> {
  Image? _networkImage;

  @override
  void initState() {
    super.initState();
    if (widget.container.attachmentType == AttachmentContainerType.remoteImage) {
      _networkImage = Image.network(
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null || loadingProgress.expectedTotalBytes == null) {
            return child;
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Get.theme.colorScheme.onPrimary,
                value: loadingProgress.expectedTotalBytes! / loadingProgress.cumulativeBytesLoaded,
              ),
            ),
          );
        },
        widget.container.url,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.container.attachmentType == AttachmentContainerType.link) {
      return Row(children: [ErrorContainer(message: "under_dev".tr)]);
    }

    //* Remote images
    if (widget.container.attachmentType == AttachmentContainerType.remoteImage) {
      return Watch((ctx) {
        if (widget.container.unsafeLocation.value) {
          final domain = TrustedLinkHelper.extractDomain(widget.container.url);

          return Container(
            padding: const EdgeInsets.all(defaultSpacing),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultSpacing),
              color: widget.self ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.public_off,
                  color: Get.theme.colorScheme.error,
                  size: Get.theme.textTheme.bodyMedium!.fontSize! * 1.5,
                ),
                horizontalSpacing(elementSpacing),
                Flexible(child: Text("file.unsafe".trParams({"domain": domain}))),
                horizontalSpacing(elementSpacing),
                LoadingIconButton(
                  iconSize: 22,
                  extra: 4,
                  padding: 4,
                  onTap: () async {
                    final result = await showConfirmPopup(
                      ConfirmWindow(
                        title: "file.images.trust.title".tr,
                        text: "file.images.trust.description".trParams({"domain": domain}),
                      ),
                    );

                    if (result) {
                      await TrustedLinkHelper.addToTrustedLinks(domain);
                      widget.container.unsafeLocation.value = false;
                      // TODO: Go through all messages and make them re-check their status
                    }
                  },
                  icon: Icons.add,
                ),
              ],
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LibraryFavoriteButton(
              container: widget.container,
              child: InkWell(
                onTap: () => Get.dialog(ImagePreviewWindow(url: widget.container.url)),
                borderRadius: BorderRadius.circular(defaultSpacing),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  child: ConstrainedBox(constraints: const BoxConstraints(maxHeight: 350), child: _networkImage),
                ),
              ),
            ),
          ],
        );
      });
    }

    // Render as an audio file
    if (FileSettings.audioTypes.contains(path.extension(widget.container.name).substring(1))) {
      return AudioAttachmentPlayer(container: widget.container);
    }

    return Container(
      padding: const EdgeInsets.all(defaultSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultSpacing),
        color: widget.self ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            getIconForFileName(widget.container.name),
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
                    widget.container.name,
                    style: Get.theme.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Watch(
                    (ctx) => Text(
                      !widget.container.error.value ? formatFileSize(widget.container.size) : 'file.not_uploaded'.tr,
                      style: Get.theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          horizontalSpacing(defaultSpacing),

          //* Button
          Watch((ctx) {
            if (widget.container.downloading.value) {
              return SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Get.theme.colorScheme.onPrimary,
                  value: widget.container.percentage.value,
                ),
              );
            }

            if (widget.container.error.value) {
              return IconButton(
                onPressed: () {
                  AttachmentController.downloadAttachment(widget.container, retry: true);
                },
                icon: const Icon(Icons.refresh),
              );
            }

            if (widget.container.downloaded.value) {
              return IconButton(
                onPressed: () async {
                  final result = await OpenFile.open(widget.container.file!.path);
                  if (result.type == ResultType.error) {
                    showErrorPopup("error", result.message);
                  }
                },
                icon: const Icon(Icons.launch),
              );
            }

            return IconButton(
              onPressed: () {
                AttachmentController.downloadAttachment(widget.container);
              },
              icon: const Icon(Icons.download),
            );
          }),
        ],
      ),
    );
  }
}
