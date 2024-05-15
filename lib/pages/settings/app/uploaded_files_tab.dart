import 'dart:math';

import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadedFilesTab extends StatefulWidget {
  const UploadedFilesTab({super.key});

  @override
  State<UploadedFilesTab> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<UploadedFilesTab> {
  final files = ["deine_mutter.png", "some_note.txt", "this is hello.mp4", "music.mp3", "music.mp3", "music.mp3"].obs;
  final query = "".obs;

  final extensionMap = {
    "webp": Icons.image,
    "png": Icons.image,
    "jpg": Icons.image,
    "jpeg": Icons.image,
    "txt": Icons.text_snippet,
    "mp4": Icons.video_library,
    "mov": Icons.video_library,
    "avi": Icons.video_library,
    "av1": Icons.video_library,
    "mp3": Icons.library_music,
  };

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      maxWidth: 500,
      child: Obx(() {
        if (files.isNotEmpty) {
          return Text("No files found", style: Get.theme.textTheme.bodyLarge);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 48,
              child: Material(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(defaultSpacing * 1.5),
                  topRight: Radius.circular(defaultSpacing * 1.5),
                ),
                color: Get.theme.colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
                  child: TextField(
                    autofocus: true,
                    style: Get.theme.textTheme.labelMedium,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusColor: Get.theme.colorScheme.onPrimary,
                      iconColor: Get.theme.colorScheme.onPrimary,
                      fillColor: Get.theme.colorScheme.onPrimary,
                      hoverColor: Get.theme.colorScheme.onPrimary,
                      prefixIcon: Icon(Icons.search, color: Get.theme.colorScheme.onPrimary),
                      hintText: "files.placeholder".tr,
                    ),
                    onChanged: (value) {
                      query.value = value;
                    },
                    cursorColor: Get.theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpacing(sectionSpacing),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                      child: Text("files.favorite".tr, style: Get.theme.textTheme.labelMedium),
                    ),
                    verticalSpacing(defaultSpacing),
                    ListView.builder(
                      itemCount: files.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        final extension = file.split(".").last;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                          child: Material(
                            color: Get.theme.colorScheme.onInverseSurface,
                            borderRadius: BorderRadius.circular(10),
                            child: MouseRegion(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                hoverColor: Theme.of(context).colorScheme.primary.withAlpha(100),
                                splashColor: Theme.of(context).hoverColor,

                                //* Show file overview
                                onTap: () => {},

                                //* Friend info
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Row(
                                      children: [
                                        Icon(extensionMap[extension] ?? Icons.insert_drive_file, color: Theme.of(context).colorScheme.onPrimary),
                                        const SizedBox(width: 10),
                                        Text(file, style: Get.theme.textTheme.bodyMedium),
                                      ],
                                    ),

                                    //* Friend actions
                                    Row(
                                      children: [
                                        //* Add to call
                                        IconButton(
                                          icon: Icon(Icons.launch, color: Theme.of(context).colorScheme.onPrimary),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    verticalSpacing(sectionSpacing),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                      child: Text("files.uploaded".tr, style: Get.theme.textTheme.labelMedium),
                    ),
                    verticalSpacing(defaultSpacing),
                    ListView.builder(
                      itemCount: files.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        final extension = file.split(".").last;
                        final expiry = DateTime.now().add(Duration(days: -Random().nextInt(30)));
                        final duration = DateTime.now().difference(expiry);
                        final difference = duration.inHours / (30 * 24);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                          child: Material(
                            color: Get.theme.colorScheme.onInverseSurface,
                            borderRadius: BorderRadius.circular(10),
                            child: MouseRegion(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                hoverColor: Theme.of(context).colorScheme.primary.withAlpha(100),
                                splashColor: Theme.of(context).hoverColor,

                                //* Show file overview
                                onTap: () => {},

                                //* Friend info
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Row(
                                      children: [
                                        Icon(extensionMap[extension] ?? Icons.insert_drive_file, color: Theme.of(context).colorScheme.onPrimary),
                                        const SizedBox(width: 10),
                                        Text(file, style: Get.theme.textTheme.bodyMedium),
                                      ],
                                    ),

                                    //* Friend actions
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: defaultSpacing * 3,
                                        height: defaultSpacing * 3,
                                        child: Tooltip(
                                          message: "This file will be deleted in ${duration.inDays} days",
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            value: difference,
                                            color: Get.theme.colorScheme.onPrimary,
                                            backgroundColor: Get.theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    verticalSpacing(defaultSpacing),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
