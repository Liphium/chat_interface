import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
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
      options: dio_rs.Options(headers: {
        "Content-Type": "multipart/form-data",
        "Authorization": "Bearer $sessionToken"
      }), 
      onSendProgress: (count, total) {
        data.progress.value = count / total;
        sendLog(data.progress.value);
      },
    );

    if(res.statusCode != 200) {
      return FileUploadResponse(false, "server.error", "");
    }

    final json = res.data;
    if(!json["success"]) {
      return FileUploadResponse(false, json["error"], "");
    }

    // Copy file to cloud_files directory
    final instanceFolder = path.join((await getApplicationSupportDirectory()).path, "cloud_files");
    final dir = Directory(instanceFolder);
    await dir.create();

    final file2 = File(path.join(dir.path, json["id"].toString()));
    await file2.writeAsBytes(bytes);
    final container = AttachmentContainer(json["id"], data.file.name, json["url"], key);
    sendLog("SENT ATTACHMENT: " + container.id);
    container.downloaded.value = true;
    attachments[container.id] = container;
    db.cloudFile.insertOnConflictUpdate(container.toData());

    return FileUploadResponse(true, "success", jsonEncode(container.toJson()));
  }

  /// Find a local file
  Future<AttachmentContainer?> findLocalFile(AttachmentContainer container) async {
    if(attachments.containsKey(container.id)) {
      return attachments[container.id];
    }

    final res = await (db.cloudFile.select()..where((tbl) => tbl.id.equals(container.id))).getSingleOrNull();
    if(res != null) {
      attachments[res.id] = AttachmentContainer.fromData(res);
      attachments[res.id]!.downloaded.value = true;
      return attachments[res.id];
    }
    container.error.value = true;

    return null;
  }

  /// Download an attachment
  Future<bool> downloadAttachment(AttachmentContainer container, {bool retry = false}) async {
    if(container.downloading) return true;
    final localFile = await findLocalFile(container);
    if(localFile != null && !retry) {
      sendLog("already exists ${container.name} ${container.id}");
      return true;
    }
    attachments[container.id] = container;
    container.downloading = true;
    sendLog("Downloading ${container.name}...");
    final maxSize = Get.find<SettingController>().settings[FileSettings.maxFileSize]!.getValue();

    final json = await postRemoteJSON("/account/files/info", {
      "id": container.id,
    });

    if(!json["success"]) {
      container.error.value = true;
      return false;
    }

    final size = json["file"]["size"] / 1000.0 / 1000.0; // Convert to MB
    sendLog(size);
    if(size > maxSize) {
      container.error.value = true;
      return false;
    }

    // Download and show progress
    final res = await dio.download(
      container.url, 
      path.join(getFilePath(), container.id),
      onReceiveProgress: (count, total) {
        container.percentage.value = count/total;
      },
    );

    if(res.statusCode != 200) {
      container.error.value = true;
      container.downloaded.value = false;
      return false;
    }

    // Decrypt file
    final file = File(path.join(getFilePath(), container.id));
    final encrypted = await file.readAsBytes();
    final decrypted = decryptSymmetricBytes(encrypted, container.key);
    await file.writeAsBytes(decrypted);

    // Add to database
    await db.cloudFile.insertOnConflictUpdate(container.toData());

    container.downloading = false;
    container.error.value = false;
    container.downloaded.value = true;
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

  static Directory getFileDirectory() {
    return Directory(_cachedPath);
  }

}

class FileUploadResponse {
  final bool success;
  final String message;
  final String data;

  FileUploadResponse(this.success, this.message, this.data);
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
    return AttachmentContainer(
      json["id"],
      json["name"],
      json["url"],
      unpackageSymmetricKey(json["key"])
    );
  }

  factory AttachmentContainer.fromData(CloudFileData data) {
    return AttachmentContainer(
      data.id,
      data.name,
      data.path,
      unpackageSymmetricKey(data.key)
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "url": url,
      "key": packageSymmetricKey(key)
    };
  }

  CloudFileData toData() {
    return CloudFileData(
      id: id,
      name: name,
      path: filePath,
      key: packageSymmetricKey(key),
    );
  }
}