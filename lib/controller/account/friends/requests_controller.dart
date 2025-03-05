import 'dart:convert';

import 'package:chat_interface/services/chat/requests_service.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

import 'friend_controller.dart';

class RequestController extends GetxController {
  final requestsSent = <LPHAddress, Request>{}.obs;
  final requests = <LPHAddress, Request>{}.obs;

  void reset() {
    requests.clear();
  }

  Future<bool> loadRequests() async {
    for (RequestData data in await db.request.select().get()) {
      final address = LPHAddress.from(data.id);
      if (data.self) {
        requestsSent[address] = Request.fromEntity(data);
      } else {
        requests[address] == Request.fromEntity(data);
      }
    }

    return true;
  }

  void addSentRequestOrUpdate(Request request) {
    if (requestsSent[request.id] != null) {
      requestsSent[request.id]!.copyFrom(request);
    } else {
      requestsSent[request.id] = request;
    }
  }

  void addRequestOrUpdate(Request request) {
    if (requests[request.id] != null) {
      requests[request.id]!.copyFrom(request);
    } else {
      requests[request.id] = request;
    }
  }

  Future<bool> deleteSentRequest(Request request, {removal = true}) async {
    if (removal) {
      requestsSent.remove(request.id);
    }
    await db.request.deleteWhere((tbl) => tbl.id.equals(request.id.encode()));
    return true;
  }

  Future<bool> deleteRequest(Request request, {removal = true}) async {
    if (removal) {
      requests.remove(request.id);
    }
    await db.request.deleteWhere((tbl) => tbl.id.equals(request.id.encode()));
    return true;
  }
}

final requestsLoading = false.obs;

/// Send a new friend request to an account by name
Future<void> newFriendRequest(String name, Function(String) success) async {
  requestsLoading.value = true;

  final controller = Get.find<StatusController>();
  if (name == controller.name.value || LPHAddress.from(name) == StatusController.ownAddress) {
    showErrorPopup("request.self", "request.self.text".tr);
    requestsLoading.value = false;
    return;
  }

  // Get the unknown account from the name parameter
  UnknownAccount? profile;
  if (name.contains("@")) {
    // If it is an address, get it by using the id
    profile = await Get.find<UnknownController>().loadUnknownProfile(LPHAddress.from(name));
  } else {
    // If it is a name, then get it from the current instance by name
    profile = await Get.find<UnknownController>().getUnknownProfileByName(name);
  }

  // Check if the profile is valid
  if (profile == null) {
    showErrorPopup("request.not.found", "request.not.found.text".tr);
    requestsLoading.value = false;
    return;
  }

  // Make sure the person is not already a friend
  if (Get.find<FriendController>().friends.keys.any((a) => a == profile!.id)) {
    showErrorPopup("request.friend.exists", "request.friend.exists.text".tr);
    requestsLoading.value = false;
    return;
  }

  // Ask the user if they really want to send the friend requests (mostly cause of security concerns)
  await showConfirmPopup(ConfirmWindow(
    title: "request.confirm.title".tr,
    text: "request.confirm.text".trParams(<String, String>{
      "username": "${profile.displayName} (${profile.name})",
    }),
    onConfirm: () async {
      await RequestsService.sendOrAcceptFriendRequest(profile!);
    },
    onDecline: () {},
  ));

  requestsLoading.value = false;
  return;
}

class Request {
  LPHAddress id;
  String name;
  String displayName;
  String vaultId;
  int vaultVersion;
  int updatedAt;
  KeyStorage keyStorage;
  final loading = false.obs;

  Request(this.id, this.name, this.displayName, this.vaultId, this.vaultVersion, this.keyStorage, this.updatedAt);

  /// Get a request from the database object.
  factory Request.fromEntity(RequestData data) {
    return Request(
      LPHAddress.from(data.id),
      fromDbEncrypted(data.name),
      fromDbEncrypted(data.displayName),
      fromDbEncrypted(data.vaultId),
      data.version.toInt(),
      KeyStorage.fromJson(jsonDecode(fromDbEncrypted(data.keys))),
      data.updatedAt.toInt(),
    );
  }

  /// Get a request from a stored payload in the database.
  factory Request.fromStoredPayload(String id, int version, int updatedAt, Map<String, dynamic> json) {
    return Request(
      LPHAddress.from(json["id"]),
      json["name"],
      json["display_name"],
      "",
      0,
      KeyStorage.fromJson(json),
      updatedAt,
    );
  }

  /// Convert to a payload for the friends vault (on the server).
  String toStoredPayload(bool self) {
    final reqPayload = <String, dynamic>{
      "rq": true,
      "id": id.encode(),
      "self": self,
      "name": name,
      "display_name": displayName,
    };
    reqPayload.addAll(keyStorage.toJson());

    return jsonEncode(reqPayload);
  }

  /// Convert the request to an unknown account (for accepting the friend request).
  UnknownAccount toUnknownAccount() {
    return UnknownAccount(
      id,
      name,
      displayName,
      keyStorage.signatureKey,
      keyStorage.publicKey,
    );
  }

  /// Convert a request object to the equivalent database object.
  RequestData entity(bool self) => RequestData(
        id: id.encode(),
        name: dbEncrypted(name),
        displayName: dbEncrypted(displayName),
        vaultId: dbEncrypted(vaultId),
        version: BigInt.from(vaultVersion),
        keys: dbEncrypted(jsonEncode(keyStorage.toJson())),
        self: self,
        updatedAt: BigInt.from(updatedAt),
      );

  /// Copy all data from another request into this one.
  void copyFrom(Request request) {
    id = request.id;
    name = request.name;
    displayName = request.displayName;
    vaultId = request.vaultId;
    vaultVersion = request.vaultVersion;
    updatedAt = request.updatedAt;
    keyStorage = request.keyStorage;
  }

  /// Convert a request to a friend (for when the request is accepted)
  Friend get friend => Friend(id, name, displayName, vaultId, vaultVersion, keyStorage, updatedAt);

  /// Accept the friend request.
  ///
  /// The first element is an error if there was one.
  /// The second element is what happened if successfull (request.accepted, or sth else).
  Future<(String?, String?)> accept() async {
    // Send a request to the same guy (this thing will detect that the request already exist and then add him, this avoids code duplication)
    return RequestsService.sendOrAcceptFriendRequest(toUnknownAccount());
  }

  /// Delete a friend request.
  ///
  /// Returns an error if there was one.
  Future<String?> delete() async {
    return FriendsVault.remove(vaultId);
  }
}
