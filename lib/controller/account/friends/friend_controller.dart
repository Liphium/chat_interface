import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/controller/account/profile_picture_helper.dart';
import 'package:chat_interface/controller/account/friends/requests_controller.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/database/database_entities.dart' as dbe;
import 'package:chat_interface/pages/chat/components/library/library_manager.dart';
import 'package:chat_interface/controller/current/steps/friends_step.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/controller/current/steps/vault_step.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

part 'friends_vault.dart';

class FriendController extends GetxController {
  final friends = <LPHAddress, Friend>{}.obs;
  Timer? _timer; // Timer to refresh the friends vault every 5 minutes

  Future<bool> loadFriends() async {
    for (FriendData data in await db.friend.select().get()) {
      friends[LPHAddress.from(data.id)] = Friend.fromEntity(data);
    }

    // Start timer to refresh the vault every couple of seconds (for multi-device synchronization)
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!SetupManager.setupFinished) {
        return;
      }
      sendLog("refreshing all vaults");
      await refreshFriendsVault();
      await refreshVault();
      LibraryManager.refreshEntries();
    });
    return true;
  }

  /// Cancels the timer (should be called when reloading)
  void onReload() {
    _timer?.cancel();
  }

  void addSelf() {
    sendLog("adding self as ${StatusController.ownAddress.encode()}");
    friends[StatusController.ownAddress] = Friend.me();
  }

  void reset() {
    friends.clear();
  }

  // Add friend (also sends data to server vault)
  Future<bool> addFromRequest(Request request) async {
    sendLog("adding friend from request ${request.friend.id}");

    // Query the guy
    final guy = await Get.find<UnknownController>().loadUnknownProfile(request.id);
    if (guy == null) {
      sendLog("friend request is invalid cause couldn't find sender");
      return false;
    }

    // Check if the guy in the request has the same name and stuff (in base64 cause otherwise it doesn't work, thanks dart)
    if (base64Encode(request.keyStorage.publicKey) != base64Encode(guy.publicKey) ||
        base64Encode(guy.signatureKey) != base64Encode(request.keyStorage.signatureKey)) {
      sendLog("friend request has invalid keys");
      return false;
    }

    // Set name and display name from the server
    request.displayName = guy.displayName;
    request.name = guy.name;

    // Remove from requests controller
    Get.find<RequestController>().deleteSentRequest(request);

    // Remove request from server
    sendLog(request.vaultId);
    final friendsVault = await FriendsVault.remove(request.vaultId);
    if (!friendsVault) {
      add(request.friend); // Add regardless cause restart of the app fixes not being able to remove the guy
      return false;
    }

    // Add friend to vault
    final id = await FriendsVault.store(
      request.friend.toStoredPayload(),
      lastPacket: request.updatedAt,
      errorPopup: true,
      prefix: "friend",
    );

    // Don't add if something failed
    if (id == null) {
      return false;
    }

    // Add friend to database with vault id
    request.vaultId = id;
    add(request.friend);

    return true;
  }

  void add(Friend friend) {
    sendLog("ADDED ${friend.name}");
    friends[friend.id] = friend;
    if (friend.id != StatusController.ownAddress) {
      db.friend.insertOnConflictUpdate(friend.entity());
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

  Friend(this.id, this.name, String displayName, this.vaultId, this.keyStorage, this.updatedAt, {this.unknown = false}) {
    this.displayName.value = displayName;
  }

  /// The friend for a system component (used in system messages for members)
  factory Friend.system() {
    return Friend(LPHAddress(basePath, "system"), "system", "system", "", KeyStorage.empty(), 0);
  }

  /// Own account as a friend (used to make implementations simpler)
  factory Friend.me([StatusController? controller]) {
    controller ??= Get.find<StatusController>();
    return Friend(
      StatusController.ownAddress,
      controller.name.value,
      controller.displayName.value,
      "",
      KeyStorage(asymmetricKeyPair.publicKey, signatureKeyPair.publicKey, profileKey, ""),
      0,
    );
  }

  /// Used for unknown accounts where only an id is known
  factory Friend.unknown(LPHAddress address) {
    sendLog(address);
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
  factory Friend.fromStoredPayload(Map<String, dynamic> json, int updatedAt) {
    return Friend(
      LPHAddress.from(json["id"]),
      json["name"],
      json["dname"],
      "",
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

  // Check if vault id is known (this would require a restart of the app)
  bool canBeDeleted() => vaultId != "";

  FriendData entity() => FriendData(
        id: id.encode(),
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
    sendLog("received $data");
    try {
      status.value = utf8.decode(base64Decode(data["s"]));
    } catch (e) {
      sendLog("no status");
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
  var profilePictureUsages = 0;
  AttachmentContainer? profilePicture;
  final profilePictureImage = Rx<ui.Image?>(null);
  bool profilePictureDataNull = false;
  DateTime lastProfilePictureUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  /// Update the profile picture of this friend
  void updateProfilePicture(AttachmentContainer? picture) async {
    if (picture == null) {
      // Delete the profile picture if it is null
      db.profile.insertOnConflictUpdate(ProfileData(
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
      db.profile.insertOnConflictUpdate(ProfileData(
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
  void loadProfilePicture() async {
    if (unknown) {
      return;
    }
    profilePictureUsages++;

    if (DateTime.now().difference(lastProfilePictureUpdate).inSeconds >= 60) {
      lastProfilePictureUpdate = DateTime.now();

      final result = await ProfileHelper.downloadProfilePicture(this);
      if (result != null) {
        return;
      }
    }

    // Return if images is already loaded
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
      return;
    }

    // Load the profile picture
    final json = jsonDecode(fromDbEncrypted(data.pictureContainer));
    final type = await AttachmentController.checkLocations(json["i"], StorageType.permanent);
    profilePicture = AttachmentContainer.fromJson(type, json);
    profilePictureImage.value = await ProfileHelper.loadImageFromBytes(await profilePicture!.file!.readAsBytes());
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
  Future<bool> remove(RxBool loading, {bool removeAction = true}) async {
    loading.value = true;

    // Remove the friend from the friends vault and local storage
    await FriendsVault.remove(vaultId);
    db.friend.deleteWhere((tbl) => tbl.id.equals(id.encode()));
    Get.find<FriendController>().friends.remove(id);

    if (removeAction) {
      // Send the other guy a notice that he's been removed from your friends list
      sendAuthenticatedStoredAction(this, authenticatedStoredAction("fr_rem", {}));
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
      controller.conversations[key]!.delete();
    }

    loading.value = false;
    return true;
  }
}
