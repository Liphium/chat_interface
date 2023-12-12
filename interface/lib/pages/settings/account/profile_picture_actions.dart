import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:get/get.dart';

/// Class for storing the data of a profile picture (scale factor, x/y position)
class ProfilePictureData {
  final double scaleFactor, moveX, moveY;
  ProfilePictureData(this.scaleFactor, this.moveX, this.moveY);

  factory ProfilePictureData.fromJson(Map<String, dynamic> json) => ProfilePictureData(
    json["s"],
    json["x"],
    json["y"],
  );

  Map<String, dynamic> toJson() => {
    "s": scaleFactor,
    "x": moveX,
    "y": moveY,
  };
}

/// Upload a profile picture to the server and set it as the current profile picture
Future<bool> uploadProfilePicture(XFile file, ProfilePictureData data) async {

  // Upload the file
  final response = await Get.find<AttachmentController>().uploadFile(UploadData(file));
  if(!response.success) {
    showErrorPopup("error", "profile_picture.not_uploaded");
    return false;
  }

  // Update the profile picture
  final json = await postAuthorizedJSON("/account/profile/set_picture", {
    "file": response.container.id,
    "data": encryptSymmetric(jsonEncode(data.toJson()), profileKey),
    "container": encryptSymmetric(jsonEncode(response.container.toJson()), profileKey)
  });

  if(!json["success"]) {
    showErrorPopup("error", "profile_picture.not_set");
    return false;
  }

  // TODO: Show somehow

  return true;
}