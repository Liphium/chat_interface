import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';
import 'package:get/get.dart';
import 'package:liphium_bridge/liphium_bridge.dart';

class ProfileHelper {
  /// Download the profile picture of a friend (if it isn't downloaded or changed).
  /// Also checks for name changes and display name changes.
  /// Returns the file ID associated with the profile picture.
  static Future<String?> downloadProfilePicture(Friend friend) async {
    // Get old profile picture
    final oldProfile = await (db.profile.select()..where((tbl) => tbl.id.equals(friend.id.encode()))).getSingleOrNull();

    final json = await postAddress(friend.id.server, "/account/profile/get", <String, dynamic>{
      "id": friend.id.id,
    });

    if (!json["success"]) {
      sendLog("ERROR WHILE GETTING PROFILE: ${json["error"]}");
      return null;
    }

    // Check if there is a new name (also handled by the profile endpoint)
    if (json["name"] != friend.name) {
      friend.name = json["name"];
      await friend.update();
    }

    // Check if there is a new display name
    final displayName = json["display_name"];
    if (displayName != friend.displayName.value) {
      friend.updateDisplayName(displayName);
    }

    sendLog("downloading ${friend.name}");

    // Check if there is a profile picture
    if ((json["profile"]["container"] ?? "") == "") {
      sendLog("no pfp found");
      // Remove the current profile picture
      await friend.updateProfilePicture(null);
      return null;
    }

    // Decrypt the profile picture data
    final containerJson = jsonDecode(decryptSymmetric(json["profile"]["container"], friend.keyStorage.profileKey));
    final container = Get.find<AttachmentController>().fromJson(StorageType.permanent, containerJson);

    String? oldPictureId;
    String? oldPath;
    if (oldProfile != null) {
      if (oldProfile.pictureContainer != "") {
        oldPictureId = jsonDecode(fromDbEncrypted(oldProfile.pictureContainer))["i"];
        oldPath = await AttachmentController.getFilePathFor(oldPictureId!);
        if (container.id == oldPictureId && oldPath != null) {
          sendLog("see no difference");
          return null; // Nothing changed
        }
      }
    }

    // Delete the old profile picture file (in case it exists)
    if (oldProfile != null && oldPath != null) {
      await fileUtil.delete(XFile(oldPath));
    }

    // Download the file
    final success = await Get.find<AttachmentController>().downloadAttachment(container, popups: false, trustPopups: true);
    if (!success) {
      sendLog("download failed");
      return null;
    }

    // Delete old profile
    if (oldProfile != null) {
      await (db.profile.delete()..where((tbl) => tbl.id.equals(friend.id.encode()))).go();
    }

    sendLog("downloaded");

    // Save the profile picture data
    await friend.updateProfilePicture(container);

    return json["profile"]["id"];
  }

  /// Upload a profile picture to the server and set it as the current profile picture
  static Future<bool> uploadProfilePicture(XFile file, String originalName, {Uint8List? bytes}) async {
    // Upload the file
    final response = await Get.find<AttachmentController>().uploadFile(
      UploadData(file),
      StorageType.permanent,
      Constants.fileAppDataTag,
      bytes: bytes,
    );
    if (response.container == null) {
      showErrorPopup("error", response.message);
      return false;
    }

    // Update the profile picture
    final json = await postAuthorizedJSON("/account/profile/set_picture", {
      "file": response.container!.id,
      "data": "", // Potentially something to be useful in the future again
      "container": encryptSymmetric(jsonEncode(response.container!.toJson()), profileKey),
    });
    if (!json["success"]) {
      showErrorPopup("error", "profile_picture.not_set".tr);
      return false;
    }

    // Set in local database
    await Get.find<FriendController>().friends[StatusController.ownAddress]!.updateProfilePicture(response.container!);

    return true;
  }

  static Future<bool> deleteProfilePicture() async {
    // Update the profile picture
    final json = await postAuthorizedJSON("/account/profile/remove_picture", {});
    if (!json["success"]) {
      showErrorPopup("error", json["error"]);
      return false;
    }

    // Set in local database
    await Get.find<FriendController>().friends[StatusController.ownAddress]!.updateProfilePicture(null);
    return true;
  }

  /// Get the file id of the profile picture of a friend
  static Future<ProfileData?> getProfileDataLocal(String id) async {
    final profile = await (db.profile.select()..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return profile;
  }

  /// Convert a file from a path to a dart:ui image
  static Future<ui.Image?> loadImage(String path) async {
    final file = XFile(path);
    if (!await doesFileExist(file)) {
      sendLog("DOESNT EXIST: $path");
      return null;
    }
    final Uint8List data = await file.readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  /// Convert bytes to a dart:ui Image
  static Future<ui.Image?> loadImageFromBytes(Uint8List data) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}
