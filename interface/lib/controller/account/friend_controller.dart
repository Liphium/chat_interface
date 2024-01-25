import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/controller/account/profile_picture_helper.dart';
import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

part 'key_container.dart';
part 'friends_vault.dart';

class FriendController extends GetxController {
  final friends = <String, Friend>{}.obs;
  final friendIdLookup = <String, Friend>{};

  Future<bool> loadFriends() async {
    for (FriendData data in await db.friend.select().get()) {
      friends[data.id] = Friend.fromEntity(data);
    }
    return true;
  }

  void addSelf() {
    friends[StatusController.ownAccountId] = Friend.me();
  }

  void reset() {
    friends.clear();
  }

  // Add friend (also sends data to server vault)
  Future<bool> addFromRequest(Request request) async {
    sendLog("adding friend from request ${request.friend.id}");

    // Remove from requests controller
    Get.find<RequestController>().deleteSentRequest(request);

    // Remove request from server
    sendLog(request.vaultId);
    final friendsVault = await removeFromFriendsVault(request.vaultId);
    if (!friendsVault) {
      add(request.friend); // Add regardless cause restart of the app fixes not being able to remove the guy
      sendLog("ADDING REGARDLESS");
      return false;
    }

    // Remove stored action from server
    await deleteStoredAction(request.storedActionId);

    // Add friend to vault
    final id = await storeInFriendsVault(request.friend.toStoredPayload());
    sendLog("STORING IN FRIENDS VAULT");

    if (id == null) {
      add(request.friend); // probably already in the vault (from other device)
      return false;
    }

    // Add friend to database with vault id
    request.vaultId = id;
    add(request.friend);

    return true;
  }

  void add(Friend friend) {
    sendLog("registered friend ${friend.id}");
    friends[friend.id] = friend;
    db.friend.insertOnConflictUpdate(friend.entity());
    friendIdLookup[friendId(friend)] = friend;
  }

  Future<bool> remove(Friend friend, {removal = true}) async {
    if (removal) {
      friends.remove(friend.id);
    }
    await db.friend.deleteWhere((tbl) => tbl.id.equals(friend.id));
    return true;
  }

  Friend getFriend(String account) {
    if (StatusController.ownAccountId == account) return Friend.me();
    return friends[account] ?? Friend.unknown(account);
  }
}

class Friend {
  String id;
  String name;
  String tag;
  String vaultId;
  KeyStorage keyStorage;
  bool unknown = false;
  Timer? _timer;
  int updatedAt;

  /// Loading state for open conversation buttons
  final openConversationLoading = false.obs;

  Friend(this.id, this.name, this.tag, this.vaultId, this.keyStorage, this.updatedAt);

  Friend.system()
      : id = "system",
        name = "System",
        tag = "fjc",
        vaultId = "",
        keyStorage = KeyStorage.empty(),
        updatedAt = 0;
  Friend.me([StatusController? controller])
      : id = '',
        name = '',
        tag = '',
        vaultId = '',
        keyStorage = KeyStorage(asymmetricKeyPair.publicKey, signatureKeyPair.publicKey, profileKey, ""),
        updatedAt = 0 {
    final StatusController statusController = controller ?? Get.find();
    id = statusController.id.value;
    name = statusController.name.value;
    tag = statusController.tag.value;
  }
  Friend.unknown(this.id)
      : name = 'fj-$id',
        tag = 'tag',
        vaultId = '',
        keyStorage = KeyStorage.empty(),
        updatedAt = 0 {
    unknown = true;
  }

  Friend.fromEntity(FriendData data)
      : id = data.id,
        name = data.name,
        tag = data.tag,
        vaultId = data.vaultId,
        keyStorage = KeyStorage.fromJson(jsonDecode(data.keys)),
        updatedAt = data.updatedAt.toInt();

  Friend.fromStoredPayload(Map<String, dynamic> json, this.updatedAt)
      : id = json["id"],
        name = json["name"],
        tag = json["tag"],
        vaultId = "",
        keyStorage = KeyStorage.fromJson(json);

  // Convert to a stored payload for the server
  String toStoredPayload() {
    final reqPayload = <String, dynamic>{
      "rq": false,
      "id": id,
      "name": name,
      "tag": tag,
    };
    reqPayload.addAll(keyStorage.toJson());

    return jsonEncode(reqPayload);
  }

  // Update in database
  Future<bool> update() async {
    if (id == StatusController.ownAccountId) {
      return false;
    }
    await removeFromFriendsVault(vaultId);
    final result = await storeInFriendsVault(toStoredPayload());
    if (result == null) {
      // TODO: Log somewhere
      sendLog("FRIEND CONFLICT: Couldn't update in vault!");
      return true;
    }
    vaultId = result;
    await db.friend.insertOnConflictUpdate(entity());
    return true;
  }

  //* Status
  final status = "-".obs;
  bool answerStatus = true;
  final statusType = 0.obs;

  void loadStatus(String message) {
    message = decryptSymmetric(message, keyStorage.profileKey);
    final data = jsonDecode(message);
    status.value = data["s"];
    statusType.value = data["t"];

    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 2), () {
      setOffline();
      answerStatus = true;
      _timer = null;
    });
  }

  void setOffline() {
    status.value = "-";
    statusType.value = 0;
  }

  //* Profile picture
  var profilePictureUsages = 0;
  AttachmentContainer? profilePicture;
  final profilePictureImage = Rx<ui.Image?>(null);
  var profilePictureData = ProfilePictureData(1, 0, 0);
  DateTime lastProfilePictureUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  /// Update the profile picture of this friend
  void updateProfilePicture(AttachmentContainer picture, ProfilePictureData data) async {
    // Update database
    db.profile.insertOnConflictUpdate(ProfileData(id: id, pictureContainer: jsonEncode(picture.toJson()), pictureData: jsonEncode(data.toJson()), data: ""));

    profilePicture = picture;
    profilePictureData = data;
    profilePictureImage.value = await ProfilePictureHelper.loadImage(picture.filePath);
  }

  /// Load the profile picture of this friend
  void loadProfilePicture() async {
    profilePictureUsages++;

    if (DateTime.now().difference(lastProfilePictureUpdate).inMinutes > 2) {
      sendLog("REDOWNLOADING");
      lastProfilePictureUpdate = DateTime.now();

      final result = await ProfilePictureHelper.downloadProfilePicture(this);
      if (result != null) {
        return;
      }
    }

    // Return if images is already loaded
    if (profilePictureImage.value != null) return;

    // Load the image
    final data = await ProfilePictureHelper.getProfileDataLocal(id);
    if (data == null) {
      sendLog("NOTHING FOUND");
      return;
    }

    final json = jsonDecode(data.pictureContainer);
    final type = await AttachmentController.checkLocations(json["id"], StorageType.permanent);
    profilePicture = AttachmentContainer.fromJson(type, json);
    profilePictureData = ProfilePictureData.fromJson(jsonDecode(data.pictureData));
    profilePictureImage.value = await ProfilePictureHelper.loadImage(profilePicture!.filePath);
    sendLog("LOADED!!");
  }

  void disposeProfilePicture() {
    profilePictureUsages--;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (profilePictureUsages <= 0) {
        profilePictureImage.value = null;
        profilePicture = null;
      }
    });
  }

  //* Remove friend
  Future<bool> remove(RxBool loading) async {
    loading.value = true;

    await removeFromFriendsVault(vaultId);
    db.friend.deleteWhere((tbl) => tbl.id.equals(id));
    Get.find<FriendController>().friends.remove(id);

    loading.value = false;
    return true;
  }

  // Check if vault id is known (this would require a restart of the app)
  bool canBeDeleted() => vaultId != "";

  FriendData entity() => FriendData(
        id: id,
        name: name,
        tag: tag,
        vaultId: vaultId,
        keys: jsonEncode(keyStorage.toJson()),
        updatedAt: BigInt.from(updatedAt),
      );
}
