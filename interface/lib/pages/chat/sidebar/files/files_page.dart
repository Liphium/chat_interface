import 'dart:math';

import 'package:chat_interface/pages/chat/sidebar/conversations/conversations_page.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<FilesPage> {

  final GlobalKey _addKey = GlobalKey();

  final files = [
    "deine_mutter.png",
    "some_note.txt",
    "this is hello.mp4",
    "music.mp3"
  ].obs;
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
      child: Obx(() {
    
        if(files.isEmpty) {
          return Center(
            child: Text(
              "No files found",
              style: Get.theme.textTheme.labelLarge
            )
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildSearchInputSidebar(Get.theme, query, hintText: "files.placeholder"),
                  horizontalSpacing(defaultSpacing * 0.5),
                  SizedBox(
                    key: _addKey,
                    width: 48,
                    height: 48,
                    child: Material(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(defaultSpacing * 1.5),
                      ),
                      color: Get.theme.colorScheme.primary,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(defaultSpacing),
                        ),
                        onTap: () {
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(defaultSpacing),
                          child: Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
                        ),
                      )
                    ),
                  ),
                ],
              ),
            ),
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
                    color: Get.theme.colorScheme.onBackground,
                    borderRadius: BorderRadius.circular(10),
                    child: MouseRegion(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        hoverColor: Theme.of(context)
                            .colorScheme
                            .primary.withAlpha(100),
                        splashColor: Theme.of(context).hoverColor,

                        //* Show file overview
                        onTap: () => {},

                        //* Friend info
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultSpacing,
                              vertical: defaultSpacing * 0.5),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(extensionMap[extension] ?? Icons.insert_drive_file,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                    const SizedBox(width: 10),
                                    Text(file, style: Get.theme.textTheme.bodyMedium),
                                  ],
                                ),

                                //* Friend actions
                                Row(
                                  children: [

                                    //* Add to call
                                    IconButton(
                                      icon: Icon(Icons.launch,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
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
                    color: Get.theme.colorScheme.onBackground,
                    borderRadius: BorderRadius.circular(10),
                    child: MouseRegion(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        hoverColor: Theme.of(context)
                            .colorScheme
                            .primary.withAlpha(100),
                        splashColor: Theme.of(context).hoverColor,

                        //* Show file overview
                        onTap: () => {},

                        //* Friend info
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultSpacing,
                              vertical: defaultSpacing * 0.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(extensionMap[extension] ?? Icons.insert_drive_file,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
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
                            ]
                          ), 
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }
}