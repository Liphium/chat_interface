import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class FileInfoWindow extends StatefulWidget {
  final AttachmentContainer container;

  const FileInfoWindow({super.key, required this.container});

  @override
  State<FileInfoWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<FileInfoWindow> {
  final _errorText = signal("");
  final _loading = signal(true);
  double _size = 0.0;

  @override
  void initState() {
    grabFileInfo();
    super.initState();
  }

  @override
  void dispose() {
    _errorText.dispose();
    _loading.dispose();
    super.dispose();
  }

  Future<void> grabFileInfo() async {
    final json = await postAuthorizedJSON("/account/files/info", {"id": widget.container.id});

    if (!json["success"]) {
      _errorText.value = json["error"];
      return;
    }

    _size = json["file"]["size"] / 1000.0 / 1000.0; // Convert to MB
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Watch((ctx) {
        // Show loading spinner
        if (_loading.value) {
          return Center(
            heightFactor: 1,
            child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary),
          );
        }

        if (_errorText.value.isNotEmpty) {
          return Center(
            heightFactor: 1,
            child: Text(_errorText.value, style: Get.textTheme.bodyMedium),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "file.dialog".trParams({
                "name": widget.container.name,
                "size": _size.toStringAsFixed(2),
              }),
              style: Get.textTheme.bodyMedium,
            ),
            verticalSpacing(defaultSpacing),
            ProfileButton(
              icon: Icons.download,
              label: "download.app".tr,
              onTap: () {
                Get.back();
              },
            ),
            verticalSpacing(elementSpacing),
            ProfileButton(
              icon: Icons.download,
              label: "download.folder".tr,
              onTap: () {
                Get.back();
              },
            ),
          ],
        );
      }),
    );
  }
}
