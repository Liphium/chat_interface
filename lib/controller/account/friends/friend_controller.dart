import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:chat_interface/main.dart';
import 'package:chat_interface/services/chat/friends_service.dart';
import 'package:chat_interface/services/chat/requests_service.dart';
import 'package:chat_interface/util/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/services/connection/chat/stored_actions_listener.dart';
import 'package:chat_interface/controller/account/profile_picture_helper.dart';
import 'package:chat_interface/controller/account/friends/requests_controller.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/database/database_entities.dart' as dbe;
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

part '../../../services/chat/friends_vault.dart';

class FriendController extends GetxController {
  final friends = <LPHAddress, Friend>{}.obs;

  Future<bool> loadFriends() async {
    for (FriendData data in await db.friend.select().get()) {
      friends[LPHAddress.from(data.id)] = Friend.fromEntity(data);
    }
    return true;
  }

  void addSelf() {
    friends[StatusController.ownAddress] = Friend.me();
  }

  void reset() {
    friends.clear();
  }

  void addOrUpdate(Friend friend) {
    if (friends[friend.id] != null) {
      friends[friend.id]!.copyFrom(friend);
    } else {
      friends[friend.id] = friend;
    }
  }

  Future<bool> remove(Friend friend, {removal = true}) async {
    if (removal) {
      friends.remove(friend.id);
    }
    await db.friend.deleteWhere((tbl) => tbl.id.equals(friend.id.encode()));
    return true;
  }

  Friend getFriend(LPHAddress address) {
    if (StatusController.ownAddress == address) return Friend.me();
    return friends[address] ?? Friend.unknown(address);
  }
}

class Friend {
  LPHAddress id;
  String name;
  String vaultId;
  int vaultVersion;
  KeyStorage keyStorage;
  bool unknown;
  Timer? _timer;
  int updatedAt;

  // Display name of the friend
  final displayName = "".obs;

  void updateDisplayName(String displayName) {
    if (id == StatusController.ownAddress) {
      return;
    }
    this.displayName.value = displayName;
    db.friend.insertOnConflictUpdate(entity());
  }

  /// Loading state for open conversation buttons
  final openConversationLoading = false.obs;

  Friend(this.id, this.name, String displayName, this.vaultId, this.vaultVersion, this.keyStorage, this.updatedAt, {this.unknown = false}) {
    this.displayName.value = displayName;
  }

  /// The friend for a system component (used in system messages for members)
  factory Friend.system() {
    return Friend(LPHAddress(basePath, "system"), "system", "system", "", 0, KeyStorage.empty(), 0);
  }

  /// Own account as a friend (used to make implementations simpler)
  factory Friend.me([StatusController? controller]) {
    controller ??= Get.find<StatusController>();
    return Friend(
      StatusController.ownAddress,
      controller.name.value,
      controller.displayName.value,
      "",
      0,
      KeyStorage.empty(),
      0,
    );
  }

  /// Used for unknown accounts where only an id is known
  factory Friend.unknown(LPHAddress address) {
    var shownId = "removed".tr;
    if (address.id.length >= 5) {
      shownId = address.id.substring(0, 5);
    }
    final friend = Friend(address, "lph-$shownId", "lph-$shownId", "", 0, KeyStorage.empty(), 0);
    friend.unknown = true;
    return friend;
  }

  /// Convert the database entity to the actual type
  factory Friend.fromEntity(FriendData data) {
    return Friend(
      LPHAddress.from(data.id),
      fromDbEncrypted(data.name),
      fromDbEncrypted(data.displayName),
      fromDbEncrypted(data.vaultId),
      data.vaultVersion.toInt(),
      KeyStorage.fromJson(jsonDecode(fromDbEncrypted(data.keys))),
      data.updatedAt.toInt(),
    );
  }

  /// Convert a json to a friend (used for friends vault)
  factory Friend.fromStoredPayload(String id, int version, int updatedAt, Map<String, dynamic> json) {
    return Friend(
      LPHAddress.from(json["id"]),
      json["name"],
      json["dname"],
      id,
      version,
      KeyStorage.fromJson(json),
      updatedAt,
    );
  }

  // Convert to a stored payload for the friends vault
  String toStoredPayload() {
    final reqPayload = <String, dynamic>{
      "rq": false, // If it is a request or not (requests are stored in the same place)
      "id": id.encode(),
      "name": name,
      "dname": displayName.value,
    };
    reqPayload.addAll(keyStorage.toJson());

    return jsonEncode(reqPayload);
  }

  /// Copy of all of the values from another friend into this one.
  void copyFrom(Friend friend) {
    id = friend.id;
    vaultId = friend.vaultId;
    vaultVersion = friend.vaultVersion;
    keyStorage = friend.keyStorage;
    displayName.value = friend.displayName.value;
    name = friend.name;
    updatedAt = friend.updatedAt;
  }

  /// Copy this friend for editing.
  Friend copy() {
    return Friend(id, name, displayName.value, vaultId, vaultVersion, keyStorage, updatedAt);
  }

  // Check if vault id is known (this would require a restart of the app)
  bool canBeDeleted() => vaultId != "";

  FriendData entity() => FriendData(
        id: id.encode(),
        vaultVersion: BigInt.from(0), // TODO: Implement vault sync for friends
        name: dbEncrypted(name),
        displayName: dbEncrypted(displayName.value),
        vaultId: dbEncrypted(vaultId),
        keys: dbEncrypted(jsonEncode(keyStorage.toJson())),
        updatedAt: BigInt.from(updatedAt),
      );

  // Update in database
  Future<bool> update() async {
    if (id == StatusController.ownAddress || unknown) {
      return false;
    }
    await FriendsVault.remove(vaultId);
    final result = await FriendsVault.store(toStoredPayload());
    if (result == null) {
      sendLog("FRIEND CONFLICT: Couldn't update in vault!");
      return true;
    }
    vaultId = result;
    await db.friend.insertOnConflictUpdate(entity());
    return true;
  }

  //* Status
  final status = "".obs;
  bool answerStatus = true;
  final statusType = 0.obs;

  void loadStatus(String message) {
    message = decryptSymmetric(message, keyStorage.profileKey);
    final data = jsonDecode(message);
    try {
      status.value = utf8.decode(base64Decode(data["s"]));
    } catch (e) {
      status.value = "";
    }
    statusType.value = data["t"];

    if (id != StatusController.ownAddress) {
      _timer?.cancel();
      _timer = Timer(const Duration(minutes: 2), () {
        setOffline();
        answerStatus = true;
        _timer = null;
      });
    }
  }

  void setOffline() {
    status.value = "";
    statusType.value = 0;
    Get.find<StatusController>().sharedContent.remove(id);
  }

  //* Profile picture
  AttachmentContainer? profilePicture;
  final profilePictureImage = Rx<ui.Image?>(null);
  bool profilePictureDataNull = false;
  DateTime lastProfilePictureUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  /// Update the profile picture of this friend
  Future<void> updateProfilePicture(AttachmentContainer? picture) async {
    if (picture == null) {
      // Delete the profile picture if it is null
      await db.profile.insertOnConflictUpdate(ProfileData(
        id: id.encode(),
        pictureContainer: "",
        data: "",
      ));

      // Update the friend as well
      profilePicture = null;
      profilePictureImage.value = null;
      profilePictureDataNull = true;
    } else {
      // Set a new profile picture if it is valid
      await db.profile.insertOnConflictUpdate(ProfileData(
        id: id.encode(),
        pictureContainer: dbEncrypted(jsonEncode(picture.toJson())),
        data: "",
      ));

      // Update in the local cache (for this friend)
      profilePicture = picture;
      profilePictureImage.value = await ProfileHelper.loadImageFromBytes(await picture.file!.readAsBytes());
    }
  }

  /// Load the profile picture of this friend
  Future<void> loadProfilePicture() async {
    if (unknown) {
      return;
    }

    // Check if we should check for changes to the profile picture
    if (DateTime.now().difference(lastProfilePictureUpdate).inMinutes >= 5) {
      lastProfilePictureUpdate = DateTime.now();

      // Query the server for updates
      final result = await ProfileHelper.downloadProfilePicture(this);
      if (result != null) {
        return;
      }

      // Set the profile picture image to null to make it reload
      profilePictureDataNull = false;
      profilePictureImage.value = null;
    }

    // Return if image is already loaded
    if (profilePictureImage.value != null || profilePictureDataNull) return;

    // Load the image
    final data = await ProfileHelper.getProfileDataLocal(id.encode());
    if (data == null) {
      profilePictureDataNull = true; // To prevent this thing from constantly loading again
      return;
    }
    profilePictureDataNull = false;

    // Check if there is a profile picture
    if (data.pictureContainer == "") {
      profilePictureDataNull = true;
      return;
    }

    // Load the profile picture
    final json = jsonDecode(fromDbEncrypted(data.pictureContainer));
    final type = await AttachmentController.checkLocations(json["i"], StorageType.permanent);
    profilePicture = Get.find<AttachmentController>().fromJson(type, json);

    // Make sure the file actually exists
    if (!await doesFileExist(profilePicture!.file!)) {
      return;
    }

    profilePictureImage.value = await ProfileHelper.loadImageFromBytes(await profilePicture!.file!.readAsBytes());
  }

  //* Remove friend
  Future<bool> remove(RxBool loading, {bool removeAction = true}) async {
    loading.value = true;

    // Remove the friend from the friends vault and local storage
    await FriendsVault.remove(vaultId);
    await db.friend.deleteWhere((tbl) => tbl.id.equals(id.encode()));
    Get.find<FriendController>().friends.remove(id);

    if (removeAction) {
      // Send the other guy a notice that he's been removed from your friends list
      await sendAuthenticatedStoredAction(this, authenticatedStoredAction("fr_rem", {}));
    }

    // Leave direct message conversations with the guy in them
    var toRemove = <LPHAddress>[];
    final controller = Get.find<ConversationController>();
    for (var conversation in controller.conversations.values) {
      if (conversation.members.values.any((mem) => mem.address == id) && conversation.type == dbe.ConversationType.directMessage) {
        toRemove.add(conversation.id);
      }
    }
    for (var key in toRemove) {
      await controller.conversations[key]!.delete();
    }

    loading.value = false;
    return true;
  }
}
