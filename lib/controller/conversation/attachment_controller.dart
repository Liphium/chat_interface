import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/status/setup/account/key_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_rs;
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:path/path.dart' as path;

class AttachmentController extends GetxController {
  final attachments = <String, AttachmentContainer>{};

  // Upload a file
  Future<FileUploadResponse> uploadFile(UploadData data, StorageType type, String tag, {popups = true, String? fileName}) async {
    final bytes = await data.file.readAsBytes();
    final key = randomSymmetricKey();
    final encrypted = encryptSymmetricBytes(bytes, key);
    final name = encryptSymmetric(fileName ?? path.basename(data.file.path), key);

    // Upload file
    final formData = dio_rs.FormData.fromMap({
      "file": dio_rs.MultipartFile.fromBytes(encrypted, filename: name),
      "name": name,
      "tag": tag,
      "key": encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, packageSymmetricKey(key)),
      "extension": path.basename(data.file.path).split(".").last
    });

    final res = await dio.post(
      server("/account/files/upload").toString(),
      data: formData,
      options: dio_rs.Options(
        headers: {
          "Content-Type": "multipart/form-data",
          "Authorization": "Bearer $sessionToken",
        },
        validateStatus: (status) => true,
      ),
      onSendProgress: (count, total) {
        data.progress.value = count / total;
        sendLog(data.progress.value);
      },
    );

    if (res.statusCode != 200) {
      return FileUploadResponse("server.error.code".trParams({"code": res.statusCode.toString()}), null);
    }

    final json = res.data;
    if (!json["success"]) {
      return FileUploadResponse(json["error"], null);
    }

    final file = File(path.join(AttachmentController.getFilePathForType(type), json["id"].toString()));
    await file.writeAsBytes(bytes);
    final container = AttachmentContainer(type, json["id"], path.basename(data.file.path), json["url"], key);
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
      return null;
    }

    container.downloaded.value = true;
    if (save) {
      attachments[container.id] = container;
    }

    return container;
  }

  /// Download an attachment
  Future<bool> downloadAttachment(AttachmentContainer container, {bool retry = false, bool popups = true}) async {
    if (container.downloading.value) return true;
    if (container.attachmentType != AttachmentContainerType.file) return false;

    final localFile = await findLocalFile(container);
    if (localFile != null && !retry) {
      // Check if there was an error already
      if (localFile.error.value) {
        return false;
      }

      sendLog("already exists ${container.name} ${container.id}");
      return true;
    }
    attachments[container.id] = container;
    container.downloading.value = true;
    sendLog("Downloading ${container.name}...");
    final maxSize = Get.find<SettingController>().settings[FileSettings.maxFileSize]!.getValue();

    final json = await postAuthorizedJSON("/account/files/info", {
      "id": container.id,
    });

    if (!json["success"]) {
      container.errorHappened(false);
      return false;
    }

    final size = json["file"]["size"] / 1000.0 / 1000.0; // Convert to MB
    if (size > maxSize) {
      container.errorHappened(false);
      return false;
    }

    // Check if the domain is trusted or ask the user to add a new one to the list of trusted providers if needed
    if (!await TrustedLinkHelper.isLinkTrusted(container.url)) {
      if (!popups) {
        container.errorHappened(true);
        return false;
      }

      final result = await TrustedLinkHelper.askToAdd(container.url);
      if (!result) {
        container.errorHappened(true);
        return false;
      }
    }

    // Download and show progress
    final res = await dio.download(
      serverPath("/account/files/download/${container.id}", instance: container.url),
      container.filePath,
      onReceiveProgress: (count, total) {
        container.percentage.value = count / total;
      },
      options: dio_rs.Options(
        validateStatus: (status) => true,
        method: "POST",
      ),
    );

    if (res.statusCode != 200) {
      container.errorHappened(false);
      return false;
    }

    // Decrypt file
    final file = File(container.filePath);
    final encrypted = await file.readAsBytes();
    final decrypted = decryptSymmetricBytes(encrypted, container.key!);
    await file.writeAsBytes(decrypted);

    container.downloading.value = false;
    container.error.value = false;
    container.downloaded.value = true;
    cleanUpCache();
    return true;
  }

  /// Delete a file
  Future<bool> deleteFile(AttachmentContainer container, {popup = false}) {
    return deleteFileFromPath(container.id, container.filePath, popup: popup);
  }

  /// Delete a file based on a path and an id
  Future<bool> deleteFileFromPath(String id, String? path, {popup = false}) async {
    if (path != null) {
      final file = File(path);
      await file.delete();
    }
    attachments.remove(id);

    // Delete from server
    final json = await postAuthorizedJSON("/account/files/delete", {
      "id": id,
    });
    if (!json["success"]) {
      if (popup) {
        showErrorPopup("error", json["error"]);
      }
      sendLog("Failed to delete file from server $id ${json["error"]}");
      return false;
    }

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
      final size = (await file.stat()).size;
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

  static void initFilePath(String accountId) async {
    // Init folder for cached files
    final cacheFolder = path.join((await getApplicationCacheDirectory()).path, ".file_cache_$accountId");
    _pathCache = cacheFolder;
    await Directory(cacheFolder).create();

    // Init folder for temporary files
    final fileFolder = path.join((await getApplicationSupportDirectory()).path, "cloud_files_$accountId");
    _pathTemporary = fileFolder;
    await Directory(fileFolder).create();

    // Init folder for permanent files
    final saveFolder = path.join((await getApplicationSupportDirectory()).path, "saved_files_$accountId");
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

  /// Check if a file exists (and get the storage type if it does)
  static Future<StorageType?> getStorageTypeFor(String id, {types = StorageType.values}) async {
    // Check if the file is in any of the existing folders
    for (final type in types) {
      final file = File(path.join(getFilePathForType(type), id));
      if (await file.exists()) {
        return type;
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

enum AttachmentContainerType { link, remoteImage, file }

class AttachmentContainer {
  late final String filePath;
  late final AttachmentContainerType attachmentType;
  final StorageType storageType;
  final String id;
  final String name;
  final String url;
  int? width;
  int? height;
  final SecureKey? key;

  // Download status
  final downloading = false.obs;
  final downloaded = false.obs;
  final error = false.obs;
  final unsafeLocation = false.obs;
  final percentage = 0.0.obs;

  void errorHappened(bool unsafe) {
    error.value = true;
    unsafeLocation.value = unsafe;
    downloading.value = false;
    downloaded.value = false;
  }

  Future<bool> init() async {
    unsafeLocation.value = !(await TrustedLinkHelper.isLinkTrusted(url));
    sendLog("TRUSTED ${unsafeLocation.value} $url");
    return true;
  }

  AttachmentContainer(this.storageType, this.id, this.name, this.url, this.key) {
    if (id == "" && name == "") {
      for (var fileType in FileSettings.imageTypes) {
        if (url.endsWith(".$fileType")) {
          attachmentType = AttachmentContainerType.remoteImage;
          return;
        }
      }
      attachmentType = AttachmentContainerType.link;
      return;
    } else {
      attachmentType = AttachmentContainerType.file;
    }
    filePath = path.join(AttachmentController.getFilePathForType(storageType), id);
  }

  Future<Size?> precalculateWidthAndHeight() async {
    if (attachmentType != AttachmentContainerType.file) {
      return null;
    }
    bool found = false;
    for (var extension in FileSettings.imageTypes) {
      if (filePath.endsWith(".$extension")) {
        found = true;
      }
    }

    if (!found) {
      return null;
    }

    // Grab resolution from it
    final buffer = await ui.ImmutableBuffer.fromUint8List(await File(filePath).readAsBytes());
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final size = Size(descriptor.width.toDouble(), descriptor.height.toDouble());

    width = size.width.toInt();
    height = size.height.toInt();

    sendLog("PRECALC $width $height");
    return size;
  }

  AttachmentContainer.remoteImage(String url) : this(StorageType.cache, "", "", url, null);

  factory AttachmentContainer.fromJson(StorageType type, Map<String, dynamic> json) {
    final container = AttachmentContainer(type, json["id"], json["name"], json["url"], unpackageSymmetricKey(json["key"]));
    container.width = json["w"];
    container.height = json["h"];
    return container;
  }

  String toAttachment() {
    switch (attachmentType) {
      case AttachmentContainerType.link:
        return url;
      case AttachmentContainerType.remoteImage:
        return url;
      case AttachmentContainerType.file:
        return jsonEncode(toJson());
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "url": url,
      "key": packageSymmetricKey(key!),
      if (width != null) "w": width,
      if (height != null) "h": height,
    };
  }
}
