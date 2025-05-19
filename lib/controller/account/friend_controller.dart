import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:chat_interface/main.dart';
import 'package:chat_interface/services/chat/friends_service.dart';
import 'package:chat_interface/services/chat/requests_service.dart';
import 'package:chat_interface/services/chat/vault_versioning_service.dart';
import 'package:chat_interface/util/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/services/chat/profile_picture_helper.dart';
import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sodium_libs/sodium_libs.dart';

part '../../services/chat/friends_vault.dart';

class FriendController {
  static final friends = mapSignal(<LPHAddress, Friend>{});

  static Future<bool> loadFriends() async {
    for (FriendData data in await db.friend.select().get()) {
      friends[LPHAddress.from(data.id)] = Friend.fromEntity(data);
    }
    return true;
  }

  static void addSelf() {
    friends[StatusController.ownAddress] = Friend.me();
  }

  static void reset() {
    friends.clear();
  }

  static void addOrUpdate(Friend friend) {
    if (friends[friend.id] != null) {
      friends[friend.id]!.copyFrom(friend);
    } else {
      friends[friend.id] = friend;
    }
  }

  static Friend getFriend(LPHAddress address) {
    if (StatusController.ownAddress == address) return Friend.me();
    return friends[address] ?? Friend.unknown(address);
  }
}

class Friend {
  LPHAddress id;
  String name;
  String vaultId;
  KeyStorage _keyStorage;
  bool unknown;
  Timer? _timer;
  int updatedAt;

  /// Get the key storage of the friend (future because the key storage of the current client may still be loading).
  Future<KeyStorage> getKeys() async {
    if (id == StatusController.ownAddress) {
      await AccountStep.keyCompleter?.future;
      return _keyStorage;
    }

    return _keyStorage;
  }

  /// Set the key storage of the friend.
  ///
  /// Should only be used for updating the key storage of the current client.
  void setKeyStorage(KeyStorage storage) {
    assert(id == StatusController.ownAddress);
    _keyStorage = storage;
  }

  // Display name of the friend
  final displayName = signal("");

  /// Loading state for open conversation buttons
  final openConversationLoading = signal(false);

  Friend(
    this.id,
    this.name,
    String displayName,
    this.vaultId,
    this._keyStorage,
    this.updatedAt, {
    this.unknown = false,
  }) {
    this.displayName.value = displayName;
  }

  /// The friend for a system component (used in system messages for members)
  factory Friend.system() {
    return Friend(LPHAddress(basePath, "system"), "system", "system", "", KeyStorage.empty(), 0);
  }

  /// Own account as a friend (used to make implementations simpler)
  factory Friend.me() {
    return Friend(
      StatusController.ownAddress,
      StatusController.name.value,
      StatusController.displayName.value,
      "",
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
    final friend = Friend(address, "lph-$shownId", "lph-$shownId", "", KeyStorage.empty(), 0);
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
      KeyStorage.fromJson(jsonDecode(fromDbEncrypted(data.keys))),
      data.updatedAt.toInt(),
    );
  }

  /// Convert a json to a friend (used for friends vault)
  factory Friend.fromStoredPayload(String id, int updatedAt, Map<String, dynamic> json) {
    return Friend(LPHAddress.from(json["id"]), json["name"], json["dname"], id, KeyStorage.fromJson(json), updatedAt);
  }

  // Convert to a stored payload for the friends vault
  Future<String> toStoredPayload() async {
    final reqPayload = <String, dynamic>{
      "rq": false, // If it is a request or not (requests are stored in the same place)
      "id": id.encode(),
      "name": name,
      "dname": displayName.value,
    };
    reqPayload.addAll((await getKeys()).toJson());

    return jsonEncode(reqPayload);
  }

  /// Copy of all of the values from another friend into this one.
  Future<void> copyFrom(Friend friend) async {
    id = friend.id;
    vaultId = friend.vaultId;
    _keyStorage = await friend.getKeys();
    displayName.value = friend.displayName.value;
    name = friend.name;
    updatedAt = friend.updatedAt;
  }

  /// Copy this friend for editing.
  Future<Friend> copy() async {
    return Friend(id, name, displayName.value, vaultId, await getKeys(), updatedAt);
  }

  // Check if vault id is known (this would require a restart of the app)
  bool canBeDeleted() => vaultId != "";

  Future<FriendData> entity() async {
    return FriendData(
      id: id.encode(),
      name: dbEncrypted(name),
      displayName: dbEncrypted(displayName.value),
      vaultId: dbEncrypted(vaultId),
      keys: dbEncrypted(jsonEncode((await getKeys()).toJson())),
      updatedAt: BigInt.from(updatedAt),
    );
  }

  //* Status
  final status = signal("");
  bool answerStatus = true;
  final statusType = signal(0);

  Future<void> loadStatus(String message) async {
    message = decryptSymmetric(message, (await getKeys()).profileKey);
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
    StatusController.sharedContent.remove(id);
  }

  //* Profile picture
  AttachmentContainer? profilePicture;
  final profilePictureImage = signal<ui.Image?>(null);
  bool profilePictureDataNull = false;
  DateTime lastProfilePictureUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  /// Update the profile picture of this friend
  Future<void> updateProfilePicture(AttachmentContainer? picture) async {
    if (picture == null) {
      // Delete the profile picture if it is null
      await db.profile.insertOnConflictUpdate(ProfileData(id: id.encode(), pictureContainer: "", data: ""));

      // Update the friend as well
      profilePicture = null;
      profilePictureImage.value = null;
      profilePictureDataNull = true;
    } else {
      // Set a new profile picture if it is valid
      await db.profile.insertOnConflictUpdate(
        ProfileData(id: id.encode(), pictureContainer: dbEncrypted(jsonEncode(picture.toJson())), data: ""),
      );

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
    profilePicture = AttachmentController.fromJson(type, json);

    // Make sure the file actually exists
    if (!await doesFileExist(profilePicture!.file!)) {
      return;
    }

    profilePictureImage.value = await ProfileHelper.loadImageFromBytes(await profilePicture!.file!.readAsBytes());

    sendLog("Profile picture set for $name");
  }

  /// Remove the friend. Just calls [FriendsService.remove] for you.
  ///
  /// Returns an error if there was one.
  Future<String?> remove({bool removeAction = true}) {
    return FriendsService.remove(this, removeAction: removeAction);
  }
}
