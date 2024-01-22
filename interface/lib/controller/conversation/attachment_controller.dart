import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_rs;
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:path/path.dart' as path;

class AttachmentController extends GetxController {
  AttachmentController() {
    initFilePath();
  }

  final attachments = <String, AttachmentContainer>{};

  // Upload a file
  Future<FileUploadResponse> uploadFile(UploadData data, StorageType type) async {
    final bytes = await data.file.readAsBytes();
    final key = randomSymmetricKey();
    final encrypted = encryptSymmetricBytes(bytes, key);
    final name = encryptSymmetric(data.file.name, key);

    // Upload file
    final formData = dio_rs.FormData.fromMap({
      "file": dio_rs.MultipartFile.fromBytes(encrypted, filename: name),
      "name": name,
      "key": encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, packageSymmetricKey(key)),
      "extension": data.file.name.split(".").last
    });

    sendLog(server("/account/files/upload").toString());
    final res = await dio.post(
      server("/account/files/upload").toString(),
      data: formData,
      options: dio_rs.Options(headers: {"Content-Type": "multipart/form-data", "Authorization": "Bearer $sessionToken"}),
      onSendProgress: (count, total) {
        data.progress.value = count / total;
        sendLog(data.progress.value);
      },
    );

    if (res.statusCode != 200) {
      return FileUploadResponse("server.error", null);
    }

    final json = res.data;
    if (!json["success"]) {
      return FileUploadResponse(json["error"], null);
    }

    final file = File(path.join(AttachmentController.getFilePathForType(type), json["id"].toString()));
    await file.writeAsBytes(bytes);
    final container = AttachmentContainer(StorageType.temporary, json["id"], data.file.name, json["url"], key);
    sendLog("SENT ATTACHMENT: ${container.id}");
    container.downloaded.value = true;
    attachments[container.id] = container;

    return FileUploadResponse("success", container);
  }

  /// Find a local file
  Future<AttachmentContainer?> findLocalFile(AttachmentContainer container, {save = true}) async {
    if (attachments.containsKey(container.id)) {
      return attachments[container.id];
    }

    final file = File(container.filePath);
    final exists = await file.exists();
    if (!exists) {
      container.error.value = true;
      return null;
    }

    container.downloaded.value = true;
    if (save) {
      attachments[container.id] = container;
    }

    return container;
  }

  /// Download an attachment
  Future<bool> downloadAttachment(AttachmentContainer container, {bool retry = false}) async {
    if (container.downloading) return true;
    final localFile = await findLocalFile(container);
    if (localFile != null && !retry) {
      sendLog("already exists ${container.name} ${container.id}");
      return true;
    }
    attachments[container.id] = container;
    container.downloading = true;
    sendLog("Downloading ${container.name}...");
    final maxSize = Get.find<SettingController>().settings[FileSettings.maxFileSize]!.getValue();

    final json = await postAuthorizedJSON("/account/files/info", {
      "id": container.id,
    });

    if (!json["success"]) {
      container.error.value = true;
      return false;
    }

    final size = json["file"]["size"] / 1000.0 / 1000.0; // Convert to MB
    sendLog(size);
    if (size > maxSize) {
      return false;
    }

    // Download and show progress
    final res = await dio.download(
      container.url,
      container.filePath,
      onReceiveProgress: (count, total) {
        container.percentage.value = count / total;
      },
    );

    if (res.statusCode != 200) {
      container.error.value = true;
      container.downloaded.value = false;
      return false;
    }

    // Decrypt file
    final file = File(container.filePath);
    final encrypted = await file.readAsBytes();
    final decrypted = decryptSymmetricBytes(encrypted, container.key);
    await file.writeAsBytes(decrypted);

    container.downloading = false;
    container.error.value = false;
    container.downloaded.value = true;
    cleanUpCache();
    return true;
  }

  /// Clean the cache until the size is below the max cache size
  void cleanUpCache() async {
    // TODO: Test this stuff properly

    // Move into isolate in the future?
    final cacheType = Get.find<SettingController>().settings[FileSettings.fileCacheType]!.getValue();
    if (cacheType == 0) return;
    final maxSize = Get.find<SettingController>().settings[FileSettings.maxCacheSize]!.getValue() * 1000 * 1000; // Convert to bytes
    final dir = Directory(getFilePathForType(StorageType.temporary));
    final files = await dir.list().toList();
    var cacheSize = files.fold(0, (previousValue, element) => previousValue + element.statSync().size);
    if (cacheSize < maxSize) return;

    // Delete oldest files
    files.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
    for (final file in files) {
      final size = file.statSync().size;
      await file.delete();
      cacheSize -= size;
      if (cacheSize < maxSize) {
        break;
      }
    }
  }

  // Delete all files from the device
  Future<bool> deleteAllFiles() async {
    var dir = Directory(_pathTemporary);
    await dir.delete(recursive: true);
    dir = Directory(_pathCache);
    await dir.delete(recursive: true);
    dir = Directory(_pathPermanent);
    await dir.delete(recursive: true);
    return true;
  }

  static String _pathCache = "";
  static String _pathTemporary = "";
  static String _pathPermanent = "";

  static void initFilePath() async {
    // Init folder for cached files
    final cacheFolder = path.join((await getApplicationCacheDirectory()).path, ".file_cache");
    _pathCache = cacheFolder;
    await Directory(cacheFolder).create();

    // Init folder for temporary files
    final fileFolder = path.join((await getApplicationSupportDirectory()).path, "cloud_files");
    _pathTemporary = fileFolder;
    await Directory(fileFolder).create();

    // Init folder for permanent files
    final saveFolder = path.join((await getApplicationSupportDirectory()).path, "saved_files");
    _pathPermanent = saveFolder;
    await Directory(saveFolder).create();
  }

  static String getFilePathForType(StorageType type) {
    switch (type) {
      case StorageType.cache:
        return _pathCache;
      case StorageType.temporary:
        return _pathTemporary;
      case StorageType.permanent:
        return _pathPermanent;
    }
  }

  /// Get the storage type for a file (or the default type)
  static Future<StorageType> checkLocations(String id, StorageType defaultType, {types = StorageType.values}) async {
    // Check if the file is in any of the existing folders
    for (final type in types) {
      final file = File(path.join(getFilePathForType(type), id));
      if (await file.exists()) {
        return type;
      }
    }

    return defaultType;
  }

  /// Check if a file exists (and get the file path if it does)
  static Future<String?> getFilePathFor(String id, {types = StorageType.values}) async {
    // Check if the file is in any of the existing folders
    for (final type in types) {
      final file = File(path.join(getFilePathForType(type), id));
      if (await file.exists()) {
        return file.path;
      }
    }

    return null;
  }
}

/// The type of storage the file is in on device
enum StorageType {
  /// The file is stored only cached (and should be deleted after closing the app)
  cache,

  /// The file is stored as a message attachment (it will be deleted when the max file cache setting is reached, and when it is old enough)
  temporary,

  /// The file is stored permanently (for example when it's part of a deck)
  permanent,
}

class FileUploadResponse {
  final String message;
  final AttachmentContainer? container;

  FileUploadResponse(this.message, this.container);

  String get data => jsonEncode(container?.toJson());
}

class AttachmentContainer {
  late final String filePath;
  final StorageType type;
  final String id;
  final String name;
  final String url;
  final SecureKey key;

  // Download status
  bool downloading = false;
  final downloaded = false.obs;
  final error = false.obs;
  final percentage = 0.0.obs;

  AttachmentContainer(this.type, this.id, this.name, this.url, this.key) {
    filePath = path.join(AttachmentController.getFilePathForType(type), id);
  }

  factory AttachmentContainer.fromJson(StorageType type, Map<String, dynamic> json) {
    return AttachmentContainer(type, json["id"], json["name"], json["url"], unpackageSymmetricKey(json["key"]));
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{"id": id, "name": name, "url": url, "key": packageSymmetricKey(key)};
  }
}
