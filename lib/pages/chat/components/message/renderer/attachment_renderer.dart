import 'dart:io';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/database/accounts/trusted_links.dart';
import 'package:chat_interface/pages/chat/components/library/library_favorite_button.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/ui/dialogs/attachment_window.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_app_file/open_app_file.dart';

class AttachmentRenderer extends StatefulWidget {
  final AttachmentContainer container;

  const AttachmentRenderer({super.key, required this.container});

  @override
  State<AttachmentRenderer> createState() => _AttachmentRendererState();
}

class _AttachmentRendererState extends State<AttachmentRenderer> {
  final loading = false.obs;
  final linkTrusted = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.container.attachmentType == AttachmentContainerType.remoteImage) {
      tryLink();
    }
  }

  void tryLink() async {
    loading.value = true;
    linkTrusted.value = await TrustedLinkHelper.isLinkTrusted(widget.container.url);
    loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.container.error.value) {
        return Row(
          children: [
            ErrorContainer(message: "file.not_uploaded".tr),
            horizontalSpacing(defaultSpacing),
            SizedBox(
              width: 35,
              height: 35,
              child: IconButton(
                onPressed: () => Get.find<AttachmentController>().downloadAttachment(widget.container, retry: true),
                iconSize: 20,
                icon: const Icon(Icons.refresh),
              ),
            ),
          ],
        );
      }

      if (widget.container.attachmentType == AttachmentContainerType.link) {
        return Row(
          children: [
            ErrorContainer(message: "under_dev".tr),
          ],
        );
      }

      //* Remote images
      if (widget.container.attachmentType == AttachmentContainerType.remoteImage) {
        if (loading.value) {
          return Container(
            padding: const EdgeInsets.all(defaultSpacing),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultSpacing),
              color: Get.theme.colorScheme.primaryContainer,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Get.theme.colorScheme.onPrimary,
                    strokeWidth: 3,
                  ),
                ),
                horizontalSpacing(defaultSpacing),
                Text("image.loading".tr)
              ],
            ),
          );
        }

        if (!linkTrusted.value) {
          return const SizedBox();
        }

        return LibraryFavoriteButton(
          container: widget.container,
          child: InkWell(
            onTap: () => Get.dialog(ImagePreviewWindow(url: widget.container.url)),
            borderRadius: BorderRadius.circular(defaultSpacing),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(defaultSpacing),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 350,
                ),
                child: Image.network(
                  widget.container.url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }

      if (!widget.container.downloaded.value) {
        final percentage = widget.container.percentage.value;
        return Container(
          padding: const EdgeInsets.all(defaultSpacing),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultSpacing),
            color: Get.theme.colorScheme.primaryContainer,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: percentage == 0 ? null : percentage,
                  color: Get.theme.colorScheme.onPrimary,
                  strokeWidth: 3,
                ),
              ),
              horizontalSpacing(defaultSpacing),
              Text("file.downloading".tr)
            ],
          ),
        );
      }

      final type = widget.container.id.split(".").last;
      if (FileSettings.imageTypes.contains(type)) {
        return LibraryFavoriteButton(
          container: widget.container,
          child: InkWell(
            onTap: () => Get.dialog(ImagePreviewWindow(file: File(widget.container.filePath))),
            borderRadius: BorderRadius.circular(defaultSpacing),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(defaultSpacing),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 350,
                ),
                child: Image.file(
                  File(widget.container.filePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(defaultSpacing),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultSpacing),
          color: Get.theme.colorScheme.primaryContainer,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_copy, color: Get.theme.colorScheme.onPrimary),
            horizontalSpacing(defaultSpacing),
            Text(widget.container.name, style: Get.theme.textTheme.labelMedium),
            horizontalSpacing(defaultSpacing),
            SizedBox(
              width: 35,
              height: 35,
              child: IconButton(
                onPressed: () async {
                  final result = await OpenAppFile.open(widget.container.filePath);
                  if (result.type == ResultType.error) {
                    showErrorPopup("error", result.message);
                  }
                },
                iconSize: 20,
                icon: const Icon(Icons.launch),
              ),
            ),
          ],
        ),
      );
    });
  }
}
