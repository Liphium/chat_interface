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
  Future<FileUploadResponse> uploadFile(UploadData data) async {
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
      return FileUploadResponse(false, "server.error", AttachmentContainer("", "", "", key));
    }

    final json = res.data;
    if (!json["success"]) {
      return FileUploadResponse(false, json["error"], AttachmentContainer("", "", "", key));
    }

    // Copy file to cloud_files directory
    final instanceFolder = path.join((await getApplicationSupportDirectory()).path, "cloud_files");
    final dir = Directory(instanceFolder);
    await dir.create();

    final file2 = File(path.join(dir.path, json["id"].toString()));
    await file2.writeAsBytes(bytes);
    final container = AttachmentContainer(json["id"], data.file.name, json["url"], key);
    sendLog("SENT ATTACHMENT: ${container.id}");
    container.downloaded.value = true;
    attachments[container.id] = container;

    return FileUploadResponse(true, "success", container);
  }

  /// Find a local file
  Future<AttachmentContainer?> findLocalFile(AttachmentContainer container) async {
    if (attachments.containsKey(container.id)) {
      return attachments[container.id];
    }

    final file = File(getFilePathForId(container.id));
    final exists = await file.exists();
    if (!exists) {
      container.error.value = true;
      return null;
    }

    container.downloaded.value = true;
    attachments[container.id] = container;

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
      container.error.value = true;
      return false;
    }

    // Download and show progress
    final res = await dio.download(
      container.url,
      path.join(getFilePath(), container.id),
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
    final file = File(path.join(getFilePath(), container.id));
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
    final maxSize = Get.find<SettingController>().settings[FileSettings.maxCacheSize]!.getValue() * 1000 * 1000; // Convert to bytes
    final dir = Directory(getFilePath());
    final files = await dir.list().toList();
    var cacheSize = files.fold(0, (previousValue, element) => previousValue + element.statSync().size);
    sendLog("Cache size: $cacheSize");
    if (cacheSize < maxSize) return;

    // Delete oldest files
    files.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
    for (final file in files) {
      final size = file.statSync().size;
      await file.delete();
      sendLog("Deleted file ${file.path} with size $size");
      cacheSize -= size;
      if (cacheSize < maxSize) {
        break;
      }
    }
  }

  // Delete all files from the device with a specific account id
  Future<bool> deleteAllFiles() async {
    final dir = Directory(getFilePath());
    for (var file in dir.listSync()) {
      await file.delete();
    }
    return true;
  }

  static String _cachedPath = "";

  static void initFilePath() async {
    final fileFolder = path.join((await getApplicationSupportDirectory()).path, "cloud_files");
    final dir = Directory(fileFolder);
    _cachedPath = dir.path;
    await dir.create();
  }

  static String getFilePath() {
    return _cachedPath;
  }

  static String getFilePathForId(String id) {
    return path.join(_cachedPath, id);
  }

  static Directory getFileDirectory() {
    return Directory(_cachedPath);
  }
}

class FileUploadResponse {
  final bool success;
  final String message;
  final AttachmentContainer container;

  FileUploadResponse(this.success, this.message, this.container);

  String get data => jsonEncode(container.toJson());
}

class AttachmentContainer {
  late final String filePath;
  final String id;
  final String name;
  final String url;
  final SecureKey key;

  // Download status
  bool downloading = false;
  final downloaded = false.obs;
  final error = false.obs;
  final percentage = 0.0.obs;

  AttachmentContainer(this.id, this.name, this.url, this.key) {
    filePath = path.join(AttachmentController.getFilePath(), id);
  }

  factory AttachmentContainer.fromJson(Map<String, dynamic> json) {
    return AttachmentContainer(json["id"], json["name"], json["url"], unpackageSymmetricKey(json["key"]));
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{"id": id, "name": name, "url": url, "key": packageSymmetricKey(key)};
  }
}