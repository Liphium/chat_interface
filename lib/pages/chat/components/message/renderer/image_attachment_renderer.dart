import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/library/library_favorite_button.dart';
import 'package:chat_interface/theme/ui/dialogs/image_preview_window.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liphium_bridge/liphium_bridge.dart';
import 'package:signals/signals_flutter.dart';

class ImageAttachmentRenderer extends StatefulWidget {
  final bool hoverCheck;
  final AttachmentContainer image;

  const ImageAttachmentRenderer({super.key, required this.image, this.hoverCheck = false});

  @override
  State<ImageAttachmentRenderer> createState() => _ImageAttachmentRendererState();
}

class _ImageAttachmentRendererState extends State<ImageAttachmentRenderer> {
  @override
  Widget build(BuildContext context) {
    final width = widget.image.width!.toDouble();
    final height = widget.image.height!.toDouble();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 350),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(defaultSpacing),
        child: AspectRatio(
          aspectRatio: width / height,
          child: Watch((ctx) {
            if (widget.image.downloading.value) {
              return Container(
                width: width,
                height: height,
                color: Get.theme.colorScheme.primaryContainer,
                child: Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary, value: widget.image.percentage.value, strokeWidth: 5),
                  ),
                ),
              );
            }

            if (widget.image.error.value) {
              return Container(
                width: width,
                height: height,
                color: Get.theme.colorScheme.primaryContainer,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      AttachmentController.downloadAttachment(widget.image, retry: true);
                    },
                    icon: const Icon(Icons.refresh, size: 40),
                  ),
                ),
              );
            }

            if (!widget.image.downloaded.value) {
              return Container(
                width: width,
                height: height,
                color: Get.theme.colorScheme.primaryContainer,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      AttachmentController.downloadAttachment(widget.image);
                    },
                    icon: const Icon(Icons.download, size: 40),
                  ),
                ),
              );
            }

            return SizedBox(
              width: width,
              height: height,
              child: LibraryFavoriteButton(
                container: widget.image,
                onEnter: () {
                  if (widget.hoverCheck) {
                    MessageController.hoveredAttachment = widget.image;
                  }
                },
                onExit: () {
                  MessageController.hoveredAttachment = widget.image;
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Get.dialog(ImagePreviewWindow(file: widget.image.file!)),
                    child: XImage(file: widget.image.file!, fit: BoxFit.fill, width: double.infinity, height: double.infinity),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
