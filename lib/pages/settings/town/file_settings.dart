import 'dart:async';

import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/town/server_file_viewer.dart';
import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/components/double_selection.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:signals/signals_flutter.dart';

class FileSettings {
  // Auto download
  static const String autoDownloadImages = "auto_download.images";
  static const String autoDownloadVideos = "auto_download.videos";
  static const String autoDownloadAudio = "auto_download.audio";
  static const String maxFileSize = "auto_download.max_size"; // MB

  // Maximum size of files stored in the cache
  static const String fileCacheType = "files.cache_type";
  static const String maxCacheSize = "files.max_cache_size"; // MB

  static var fileCacheTypes = [
    SelectableItem("settings.file.cache_type.unlimited".tr, Icons.all_inclusive),
    SelectableItem("settings.file.cache_type.size".tr, Icons.filter_alt),
  ];

  // File types for auto download
  static const List<String> staticImageTypes = ["png", "jpg", "jpeg", "webp", "bmp", "wbmp"]; // Everything except GIF
  static const List<String> imageTypes = ["png", "jpg", "jpeg", "webp", "bmp", "wbmp", "gif"];
  static const List<String> videoTypes = ["mp4", "avi", "mkv"];
  static const List<String> audioTypes = ["mp3", "mov", "wav", "ogg"];

  /// Checks if the file passed in is a audio, video or image file with the types above
  static bool isMediaFile(String name) {
    final ext = path.extension(name).substring(1).toLowerCase();
    sendLog("Extension of $name: $ext");
    return imageTypes.contains(ext) || audioTypes.contains(ext) || videoTypes.contains(ext);
  }

  static void addSettings() {
    SettingController.addSetting(Setting<bool>(autoDownloadImages, isWeb ? false : true));
    SettingController.addSetting(Setting<bool>(autoDownloadVideos, false));
    SettingController.addSetting(Setting<bool>(autoDownloadAudio, false));
    SettingController.addSetting(Setting<double>(maxFileSize, isWeb ? 1.0 : 5.0));
    SettingController.addSetting(Setting<double>(maxCacheSize, 500.0));
    SettingController.addSetting(Setting<int>(fileCacheType, 0));
  }
}

class FileSettingsPage extends StatelessWidget {
  const FileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "files",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Auto download types
          Text("settings.file.auto_download.types".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          const BoolSettingSmall(settingName: FileSettings.autoDownloadImages),
          const BoolSettingSmall(settingName: FileSettings.autoDownloadVideos),
          const BoolSettingSmall(settingName: FileSettings.autoDownloadAudio),
          verticalSpacing(sectionSpacing),

          //* Max file size
          Text("settings.file.max_size".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          const DoubleSelectionSetting(
            settingName: FileSettings.maxFileSize,
            description: "settings.file.max_size.description",
            min: 1.0,
            max: 10.0,
            unit: "settings.file.mb",
          ),
          verticalSpacing(sectionSpacing),

          //* File cache size
          Text("settings.file.cache".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          Text("settings.file.cache.description".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing + elementSpacing),

          ListSelectionSetting(
            setting: SettingController.settings[FileSettings.fileCacheType]! as Setting<int>,
            items: FileSettings.fileCacheTypes,
          ),

          Watch(
            (ctx) => Visibility(
              visible: SettingController.settings[FileSettings.fileCacheType]!.getValue() == 1,
              child: const DoubleSelectionSetting(
                settingName: FileSettings.maxCacheSize,
                description: "",
                min: 100.0,
                max: 3000.0,
                unit: "settings.file.mb",
              ),
            ),
          ),
          verticalSpacing(defaultSpacing),
          Visibility(
            visible: !GetPlatform.isMobile,
            child: Wrap(
              spacing: defaultSpacing,
              children: [
                FJElevatedButton(
                  onTap: () async {
                    final cacheFolder = path.join(
                      (await getApplicationCacheDirectory()).path,
                      ".file_cache_${StatusController.ownAccountId}",
                    );
                    unawaited(OpenFile.open(cacheFolder));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.launch, color: Get.theme.colorScheme.onPrimary),
                      horizontalSpacing(defaultSpacing),
                      Text("settings.file.cache.open_cache".tr, style: Get.textTheme.labelLarge),
                    ],
                  ),
                ),
                FJElevatedButton(
                  onTap: () async {
                    final fileFolder = path.join(
                      (await getApplicationSupportDirectory()).path,
                      "saved_files_${StatusController.ownAccountId}",
                    );
                    unawaited(OpenFile.open(fileFolder));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.launch, color: Get.theme.colorScheme.onPrimary),
                      horizontalSpacing(defaultSpacing),
                      Text("settings.file.cache.open_saved_files".tr, style: Get.textTheme.labelLarge),
                    ],
                  ),
                ),
                FJElevatedButton(
                  onTap: () async {
                    final fileFolder = path.join(
                      (await getApplicationSupportDirectory()).path,
                      "cloud_files_${StatusController.ownAccountId}",
                    );
                    unawaited(OpenFile.open(fileFolder));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.launch, color: Get.theme.colorScheme.onPrimary),
                      horizontalSpacing(defaultSpacing),
                      Text("settings.file.cache.open_files".tr, style: Get.textTheme.labelLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
          verticalSpacing(sectionSpacing + defaultSpacing),

          //* Uploaded files
          const ServerFileViewer(),
        ],
      ),
    );
  }
}
