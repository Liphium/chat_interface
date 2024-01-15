import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/components/double_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileSettings {
  // Auto download
  static const String autoDownloadImages = "auto_download.images";
  static const String autoDownloadVideos = "auto_download.videos";
  static const String autoDownloadAudio = "auto_download.audio";
  static const String maxFileSize = "auto_download.max_size"; // MB

  // Maximum size of files stored in the cache
  static const String maxCacheSize = "files.max_cache_size"; // MB

  // File types for auto download
  static const List<String> imageTypes = ["png", "jpg", "jpeg", "gif"];
  static const List<String> videoTypes = ["mp4", "mov", "avi", "mkv"];
  static const List<String> audioTypes = ["mp3", "wav", "ogg"];

  static void addSettings(SettingController controller) {
    controller.settings[autoDownloadImages] = Setting<bool>(autoDownloadImages, true);
    controller.settings[autoDownloadVideos] = Setting<bool>(autoDownloadVideos, false);
    controller.settings[autoDownloadAudio] = Setting<bool>(autoDownloadAudio, false);
    controller.settings[maxFileSize] = Setting<double>(maxFileSize, 5.0);
    controller.settings[maxCacheSize] = Setting<double>(maxCacheSize, 500.0);
  }
}

class FileSettingsPage extends StatelessWidget {
  const FileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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

        //* Max file size
        Text("settings.file.cache".tr, style: Get.theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),

        const DoubleSelectionSetting(
          settingName: FileSettings.maxCacheSize,
          description: "settings.file.cache.description",
          min: 100.0,
          max: 3000.0,
          unit: "settings.file.mb",
        ),
      ],
    );
  }
}
