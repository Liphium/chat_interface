import 'package:chat_interface/util/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_zap_renderer.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sodium_libs/sodium_libs.dart';

class ServerFileViewer extends StatefulWidget {
  const ServerFileViewer({super.key});

  @override
  State<ServerFileViewer> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ServerFileViewer> with SignalsMixin {
  final files = RxList<FileContainer>.empty();
  final query = "".obs;
  final startLoading = signal(true);
  final pageLoading = signal(false);
  final currentPage = 0.obs;
  final totalCount = 0.obs;
  final storageLine = "loading".tr.obs;

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
  void initState() {
    goToPage(0);
    getStorageData();
    super.initState();
  }

  Future<void> getStorageData() async {
    final json = await postAuthorizedJSON("/account/files/storage", {});
    if (!json["success"]) {
      storageLine.value = json["error"];
      return;
    }
    storageLine.value = "settings.file.uploaded.description".trParams({
      "current": formatFileSize(json["amount"]),
      "max": formatFileSize(json["max"]),
    });
  }

  Future<void> goToPage(int page) async {
    // Set the current page
    if (pageLoading.value) {
      return;
    }
    pageLoading.value = true;
    currentPage.value = page;

    // Get the files from the server
    final json = await postAuthorizedJSON("/account/files/list", {
      "page": page,
    });
    startLoading.value = false;
    pageLoading.value = false;

    // Check if there was an error
    if (!json["success"]) {
      showErrorPopup("error", json["error"]);
      return;
    }

    // Parse the entire json
    if (json["files"] == null) {
      files.clear();
      return;
    }

    // Set the total amount of files
    totalCount.value = json["count"];

    // Decrypt some stuff in an isolate
    final list = await sodiumLib.runIsolated((sodium, secureKeys, keyPairs) async {
      final list = <FileContainer>[];

      for (var file in json["files"]) {
        list.add(FileContainer.fromJson(file, keyPairs[0], sodium));
      }

      return list;
    }, keyPairs: [asymmetricKeyPair]);

    // Check the file locations
    for (var file in list) {
      file.path = await AttachmentController.getFilePathFor(file.id);
    }

    // Update the UI
    files.value = list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            "settings.file.uploaded.title".trParams({
              "count": totalCount.value.toString(),
            }),
            style: Get.theme.textTheme.labelLarge,
          ),
        ),
        verticalSpacing(defaultSpacing),
        Obx(() => Text(storageLine.value, style: Get.theme.textTheme.bodyMedium)),
        verticalSpacing(defaultSpacing),
        Obx(() {
          if (startLoading.value) {
            return CircularProgressIndicator(
              color: Get.theme.colorScheme.onPrimary,
            );
          }

          if (!files.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: elementSpacing),
              child: Text("settings.file.uploaded.none".tr, style: Get.theme.textTheme.labelMedium),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageSwitcher(
                loading: pageLoading,
                currentPage: currentPage,
                count: totalCount,
                page: (page) => goToPage(page),
              ),
              verticalSpacing(defaultSpacing),
              ListView.builder(
                itemCount: files.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final file = files[index];
                  final extension = file.id.split(".").last;

                  return Obx(
                    () => Animate(
                      key: ValueKey(file.id),
                      effects: [
                        ReverseExpandEffect(
                          axis: Axis.vertical,
                          curve: const ElasticOutCurve(2.0),
                          duration: 1000.ms,
                        ),
                        ScaleEffect(
                          begin: const Offset(1, 1),
                          end: const Offset(0, 0),
                          curve: Curves.ease,
                          duration: 1000.ms,
                        ),
                        FadeEffect(
                          begin: 1,
                          end: 0,
                          duration: 1000.ms,
                        )
                      ],
                      onInit: (controller) => controller.value = file.deleted.value ? 1 : 0,
                      target: file.deleted.value ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: defaultSpacing),
                        child: Material(
                          color: Get.theme.colorScheme.onInverseSurface,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Icon(
                                        extensionMap[extension] ?? Icons.insert_drive_file,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        size: 30,
                                      ),
                                      horizontalSpacing(defaultSpacing),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(file.name, style: Get.theme.textTheme.labelMedium),
                                            Text(formatFileSize(file.size), style: Get.theme.textTheme.bodyMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                //* File actions
                                Row(
                                  children: [
                                    Icon(
                                      file.path == null ? Icons.cloud_off : Icons.cloud_done,
                                      color: Get.theme.colorScheme.onPrimary,
                                    ),
                                    horizontalSpacing(defaultSpacing + elementSpacing),
                                    if (file.path != null)
                                      IconButton(
                                        onPressed: () => OpenFile.open(file.path!),
                                        icon: const Icon(Icons.launch),
                                      ),
                                    LoadingIconButton(
                                      loading: file.deleteLoading,
                                      onTap: () async {
                                        if (file.deleteLoading.value) {
                                          return;
                                        }
                                        file.deleteLoading.value = true;

                                        // Make a request to the server
                                        final success = await AttachmentController.deleteFileFromPath(
                                          file.id,
                                          file.path != null ? XFile(file.path!) : null,
                                          popup: true,
                                        );
                                        if (!success) {
                                          file.path = null;
                                        }

                                        // Play the deleted animation
                                        file.deleted.value = true;
                                      },
                                      icon: Icons.delete,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              PageSwitcher(
                loading: pageLoading,
                currentPage: currentPage,
                count: totalCount,
                page: (page) => goToPage(page),
              ),
              verticalSpacing(defaultSpacing),
            ],
          );
        })
      ],
    );
  }
}

class PageSwitcher extends StatefulWidget {
  final RxInt currentPage;
  final RxInt count;
  final Signal<bool> loading;
  final Function(int) page;

  const PageSwitcher({
    super.key,
    required this.currentPage,
    required this.count,
    required this.loading,
    required this.page,
  });

  @override
  State<PageSwitcher> createState() => _PageSwitcherState();
}

class _PageSwitcherState extends State<PageSwitcher> {
  int getMaxPage() => (widget.count.value / 20).ceil();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LoadingIconButton(
          loading: widget.loading,
          onTap: () {
            if (widget.currentPage.value == 0) {
              return;
            }
            widget.page(0);
          },
          icon: Icons.skip_previous,
        ),
        horizontalSpacing(elementSpacing),
        LoadingIconButton(
          loading: widget.loading,
          onTap: () {
            if (widget.currentPage.value == 0) {
              return;
            }
            widget.page(widget.currentPage.value - 1);
          },
          icon: Icons.arrow_back,
        ),
        const Spacer(),
        Obx(
          () => Text(
            "page_switcher".trParams({
              "count": (widget.currentPage.value + 1).toString(),
              "max": getMaxPage().toString(),
            }),
            style: Get.textTheme.labelLarge,
          ),
        ),
        const Spacer(),
        LoadingIconButton(
          loading: widget.loading,
          onTap: () {
            if (widget.currentPage.value == getMaxPage() - 1) {
              return;
            }
            widget.page(widget.currentPage.value + 1);
          },
          icon: Icons.arrow_forward,
        ),
        horizontalSpacing(elementSpacing),
        LoadingIconButton(
          loading: widget.loading,
          onTap: () {
            if (widget.currentPage.value == getMaxPage() - 1) {
              return;
            }
            widget.page(getMaxPage() - 1);
          },
          icon: Icons.skip_next,
        ),
      ],
    );
  }
}

class FileContainer {
  String id;
  String name;
  String type;
  String key;
  String account;
  int size;
  String tag;
  bool system;
  int createdAt;
  String? path;
  final deleteLoading = signal(false);
  final deleted = signal(false);

  FileContainer(
    this.id,
    this.name,
    this.type,
    this.key,
    this.account,
    this.size,
    this.tag,
    this.system,
    this.createdAt,
  );

  // Deserialize from JSON
  factory FileContainer.fromJson(Map<String, dynamic> json, KeyPair key, [Sodium? sodium]) {
    // Get the name and stuff
    final packagedKey = decryptAsymmetricAnonymous(key.publicKey, key.secretKey, json["key"], sodium);
    final name = decryptSymmetric(json["name"], unpackageSymmetricKey(packagedKey, sodium), sodium);

    return FileContainer(
      json['id'],
      name,
      json['type'],
      json['key'],
      json['account'],
      json['size'],
      json['tag'],
      json['system'] ?? false,
      json['created'],
    );
  }
}
