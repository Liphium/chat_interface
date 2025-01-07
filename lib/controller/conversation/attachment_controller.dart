import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_rs;
import 'package:liphium_bridge/liphium_bridge.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:path/path.dart' as path;

class AttachmentController extends GetxController {
  final attachments = <String, AttachmentContainer>{};

  // Upload a file
  Future<FileUploadResponse> uploadFile(
    UploadData data,
    StorageType type,
    String tag, {
    popups = true,
    bool containerNameNull = false,
    Uint8List? bytes,
    String? fileName,
  }) async {
    // Check if there is a connection before doing this
    if (!Get.find<ConnectionController>().connected.value) {
      if (popups) {
        showErrorPopup("error", "error.no_connection".tr);
      }
      return FileUploadResponse("error.no_connection".tr, null);
    }

    bytes ??= await data.file.readAsBytes();
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
      ownServer("/account/files/upload"),
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

    // Copy the file into the local cache
    if (!isWeb) {
      // Only copy the file if it's a media file (other file types don't really matter because they aren't displayed)
      if (FileSettings.isMediaFile(name)) {
        final filePath = path.join(AttachmentController.getFilePathForType(type), json["id"].toString());
        await fileUtil.write(XFile(filePath), bytes);
      }
    }
    final container = AttachmentContainer(
      storageType: type,
      id: json["id"],
      fileName: containerNameNull ? null : fileName ?? path.basename(data.file.path),
      size: await data.file.length(),
      url: json["url"],
      key: key,
    );
    sendLog("UPLOADED ATTACHMENT: ${container.id}");
    container.downloaded.value = FileSettings.isMediaFile(name);
    attachments[container.id] = container;

    return FileUploadResponse("success", container);
  }

  /// Download an attachment
  Future<bool> downloadAttachment(
    AttachmentContainer container, {
    bool retry = false,
    bool popups = true,
    bool trustPopups = true,
    bool ignoreLimit = true,
  }) async {
    if (container.downloading.value) return true;
    if (container.downloaded.value) return true;
    if (container.attachmentType != AttachmentContainerType.file) return false;

    // Check if there is a connection before doing this
    if (!Get.find<ConnectionController>().connected.value) {
      if (popups) {
        showErrorPopup("error", "error.no_connection".tr);
      }
      return false;
    }

    if (await container.existsLocally() && !retry) {
      sendLog("already exists ${container.name} ${container.id}");
      return true;
    }
    attachments[container.id] = container;
    container.downloading.value = true;

    // Check if the domain is trusted or ask the user to add a new one to the list of trusted providers if needed
    if (!await TrustedLinkHelper.isLinkTrusted(container.url)) {
      if (!popups && !trustPopups) {
        container.errorHappened(true);
        return false;
      }

      final result = await TrustedLinkHelper.askToAdd(container.url);
      if (!result) {
        container.errorHappened(true);
        return false;
      }
    }

    sendLog("Downloading ${container.name}...");
    final maxSize = Get.find<SettingController>().settings[FileSettings.maxFileSize]!.getValue();

    // Check the file size to make sure it isn't over the limit
    final json = await postAddress(container.url, "/account/file_info/info", {
      "id": container.id,
    });

    if (!json["success"]) {
      if (popups) {
        showErrorPopup("error", json["error"]);
      }
      container.errorHappened(false);
      return false;
    }

    final size = json["file"]["size"] / 1024.0 / 1024.0; // Convert to MB
    if (size > maxSize && !ignoreLimit) {
      container.downloadFailed();
      return false;
    }

    // Check if the file should be saved to a directory instead of the cache
    FileSaveLocation? location;
    if (!isWeb && !FileSettings.isMediaFile(container.id)) {
      container.percentage.value = 0;
      // Let the user choose a location
      location = await getSaveLocation(suggestedName: container.fileName);
      if (location == null) {
        showErrorPopup("error", "file.no_save_location".tr);
        container.downloadFailed();
        return false;
      }
    }

    // Download and show progress
    final res = await dio.get<Uint8List>(
      serverPath(container.url, "/account/files_unencrypted/download/${container.id}").toString(),
      options: dio_rs.Options(
        responseType: dio_rs.ResponseType.bytes,
        validateStatus: (status) => true,
      ),
      onReceiveProgress: (count, total) {
        container.percentage.value = count / total;
      },
    );

    if (res.statusCode != 200 || res.data == null) {
      container.errorHappened(false);
      return false;
    }

    // Decrypt file
    final decrypted = decryptSymmetricBytes(res.data!, container.key!);
    container.file = XFile(container.file!.path, bytes: decrypted);
    if (!isWeb) {
      if (location != null) {
        await fileUtil.write(XFile(location.path), decrypted);
      } else {
        await fileUtil.write(container.file!, decrypted);
      }
    }

    container.downloading.value = false;
    container.error.value = false;
    container.downloaded.value = location == null;
    if (location != null) {
      unawaited(OpenFile.open(path.dirname(location.path)));
    }
    if (!isWeb) {
      await cleanUpCache();
    }
    return true;
  }

  /// Delete a file
  Future<bool> deleteFile(AttachmentContainer container, {popup = false}) async {
    return await deleteFileFromPath(container.id, container.file, popup: popup);
  }

  /// Delete a file based on a path and an id
  Future<bool> deleteFileFromPath(String id, XFile? file, {popup = false}) async {
    // Check if there is a connection before doing this
    if (!Get.find<ConnectionController>().connected.value) {
      if (popup) {
        showErrorPopup("error", "error.no_connection".tr);
      }
      return false;
    }

    if (file != null) {
      await fileUtil.delete(file);
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
  Future<void> cleanUpCache() async {
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
    var dir = XDirectory(_pathTemporary);
    await dir.delete(recursive: true);
    dir = XDirectory(_pathCache);
    await dir.delete(recursive: true);
    dir = XDirectory(_pathPermanent);
    await dir.delete(recursive: true);
    return true;
  }

  static String _pathCache = "";
  static String _pathTemporary = "";
  static String _pathPermanent = "";

  static Future<void> initFilePath(String accountId) async {
    if (!isWeb) {
      // Init folder for cached files
      final cacheFolder = path.join((await getApplicationCacheDirectory()).path, ".file_cache_$accountId");
      _pathCache = cacheFolder;
      await XDirectory(cacheFolder).create();

      // Init folder for temporary files
      final fileFolder = path.join((await getApplicationSupportDirectory()).path, "cloud_files_$accountId");
      _pathTemporary = fileFolder;
      await XDirectory(fileFolder).create();

      // Init folder for permanent files
      final saveFolder = path.join((await getApplicationSupportDirectory()).path, "saved_files_$accountId");
      _pathPermanent = saveFolder;
      await XDirectory(saveFolder).create();
    }
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
      final file = XFile(path.join(getFilePathForType(type), id));
      if (await doesFileExist(file)) {
        return type;
      }
    }

    return defaultType;
  }

  /// Check if a file exists (and get the file path if it does)
  static Future<String?> getFilePathFor(String id, {types = StorageType.values}) async {
    // Check if the file is in any of the existing folders
    for (final type in types) {
      final file = XFile(path.join(getFilePathForType(type), id));
      if (await doesFileExist(file)) {
        return file.path;
      }
    }

    return null;
  }

  /// Check if a file exists (and get the storage type if it does)
  static Future<StorageType?> getStorageTypeFor(String id, {types = StorageType.values}) async {
    // Check if the file is in any of the existing folders
    for (final type in types) {
      final file = XFile(path.join(getFilePathForType(type), id));
      if (await doesFileExist(file)) {
        return type;
      }
    }

    return null;
  }

  /// Get an attachment container from json
  AttachmentContainer fromJson(StorageType type, Map<String, dynamic> json, [Sodium? sodium]) {
    var container = attachments[json["i"]];
    if (container != null) {
      return container;
    }

    // Create a container and cache it immediately
    container = AttachmentContainer(
      storageType: type,
      id: json["i"],
      fileName: json["n"], // The name could be null (if it is null it'll the object in the map will also be null)
      size: json["s"] ?? -1,
      url: json["u"],
      key: unpackageSymmetricKey(json["k"], sodium),
    );
    container.width = json["w"];
    container.height = json["h"];
    attachments[container.id] = container;
    container.initDownloadState();
    return container;
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
  late XFile? file;
  late final AttachmentContainerType attachmentType;
  final StorageType storageType;
  final String id;
  final String? fileName;
  final String url;
  final int size;
  int? width;
  int? height;
  final SecureKey? key;

  // Get the file name (when name is empty it is the file id)
  String get name => fileName ?? id;

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

  void downloadFailed() {
    error.value = false;
    unsafeLocation.value = false;
    downloading.value = false;
    downloaded.value = false;
  }

  Future<bool> init() async {
    unsafeLocation.value = !(await TrustedLinkHelper.isLinkTrusted(url));
    sendLog("TRUSTED ${unsafeLocation.value} $url");
    return true;
  }

  AttachmentContainer({
    required this.storageType,
    required this.id,
    required this.fileName,
    required this.size,
    required this.url,
    required this.key,
  }) {
    setAttachmentType();
    if (attachmentType == AttachmentContainerType.file) {
      file = XFile(path.join(AttachmentController.getFilePathForType(storageType), id));
    }
  }

  void setAttachmentType() {
    if (id == "") {
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
  }

  Future<Size?> precalculateWidthAndHeight() async {
    if (attachmentType != AttachmentContainerType.file || file == null) {
      return null;
    }
    bool found = false;
    for (var extension in FileSettings.imageTypes) {
      if (path.basename(file!.path).endsWith(".$extension")) {
        found = true;
      }
    }

    if (!found) {
      return null;
    }

    // Grab resolution from it
    final buffer = await ui.ImmutableBuffer.fromUint8List(await File(file!.path).readAsBytes());
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final size = Size(descriptor.width.toDouble(), descriptor.height.toDouble());

    width = size.width.toInt();
    height = size.height.toInt();

    sendLog("PRECALC $width $height");
    return size;
  }

  AttachmentContainer.remoteImage(String url)
      : this(
          storageType: StorageType.cache,
          id: "",
          fileName: "",
          size: 0,
          url: url,
          key: null,
        );

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

  /// Check if this container exists on the local system
  Future<bool> existsLocally() async {
    if (attachmentType != AttachmentContainerType.file) {
      return false;
    }

    if (isWeb) {
      return false;
    }

    return doesFileExist(file!);
  }

  Future<void> initDownloadState() async {
    if (await existsLocally()) {
      downloaded.value = true;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "i": id,
      if (fileName != null) "n": fileName!,
      if (size != -1) "s": size,
      "u": url,
      "k": packageSymmetricKey(key!),
      if (width != null) "w": width,
      if (height != null) "h": height,
    };
  }
}
