import 'dart:convert';

import 'package:chat_interface/services/chat/requests_service.dart';
import 'package:chat_interface/services/chat/unknown_service.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

import 'friend_controller.dart';

class RequestController {
  static final requestsLoading = signal(false);
  static final requestsSent = mapSignal(<LPHAddress, Request>{});
  static final requests = mapSignal(<LPHAddress, Request>{});

  static void reset() {
    requests.clear();
  }

  static Future<bool> loadRequests() async {
    for (RequestData data in await db.request.select().get()) {
      final address = LPHAddress.from(data.id);
      final unpacked = await Request.fromEntity(data);
      if (unpacked == null) {
        sendLog("ERROR: Couldn't unencrypt request from local database");
        continue;
      }
      if (data.self) {
        requestsSent[address] = unpacked;
      } else {
        requests[address] = unpacked;
      }
    }

    return true;
  }

  static void addSentRequestOrUpdate(Request request) {
    if (requestsSent[request.id] != null) {
      requestsSent[request.id]!.copyFrom(request);
    } else {
      requestsSent[request.id] = request;
    }
  }

  static void addRequestOrUpdate(Request request) {
    if (requests[request.id] != null) {
      requests[request.id]!.copyFrom(request);
    } else {
      requests[request.id] = request;
    }
  }

  static Future<bool> deleteSentRequest(Request request, {removal = true}) async {
    if (removal) {
      requestsSent.remove(request.id);
    }
    await db.request.deleteWhere((tbl) => tbl.id.equals(request.id.encode()));
    return true;
  }

  static Future<bool> deleteRequest(Request request, {removal = true}) async {
    if (removal) {
      requests.remove(request.id);
    }
    await db.request.deleteWhere((tbl) => tbl.id.equals(request.id.encode()));
    return true;
  }
}

/// Send a new friend request to an account by name
Future<void> newFriendRequest(String name, Function(String) success) async {
  RequestController.requestsLoading.value = true;

  if (name == StatusController.name.value || LPHAddress.from(name) == StatusController.ownAddress) {
    showErrorPopup("request.self", "request.self.text".tr);
    RequestController.requestsLoading.value = false;
    return;
  }

  // Get the unknown account from the name parameter
  UnknownAccount? profile;
  if (name.contains("@")) {
    // If it is an address, get it by using the id
    profile = await UnknownService.loadUnknownProfile(LPHAddress.from(name));
  } else {
    // If it is a name, then get it from the current instance by name
    profile = await UnknownService.getUnknownProfileByName(name);
  }

  // Check if the profile is valid
  if (profile == null) {
    showErrorPopup("request.not.found", "request.not.found.text".tr);
    RequestController.requestsLoading.value = false;
    return;
  }

  // Make sure the person is not already a friend
  if (FriendController.friends.keys.any((a) => a == profile!.id)) {
    showErrorPopup("request.friend.exists", "request.friend.exists.text".tr);
    RequestController.requestsLoading.value = false;
    return;
  }

  // Ask the user if they really want to send the friend requests (mostly cause of security concerns)
  await showConfirmPopup(
    ConfirmWindow(
      title: "request.confirm.title".tr,
      text: "request.confirm.text".trParams(<String, String>{"username": "${profile.displayName} (${profile.name})"}),
      onConfirm: () async {
        await RequestsService.sendOrAcceptFriendRequest(profile!);
      },
      onDecline: () {},
    ),
  );

  RequestController.requestsLoading.value = false;
  return;
}

class Request {
  LPHAddress id;
  String name;
  String displayName;
  String vaultId;
  int updatedAt;
  KeyStorage keyStorage;
  final loading = signal(false);

  Request(this.id, this.name, this.displayName, this.vaultId, this.keyStorage, this.updatedAt);

  /// Get a request from the database object.
  static Future<Request?> fromEntity(RequestData data) async {
    final results = await Future.wait([
      fromDbEncrypted(data.name),
      fromDbEncrypted(data.displayName),
      fromDbEncrypted(data.vaultId),
      fromDbEncrypted(data.keys),
    ]);
    if (results.any((a) => a == null)) {
      return null;
    }
    final keyStorage = await KeyStorage.fromJson(jsonDecode(results[3]!));
    if (keyStorage == null) {
      return null;
    }
    return Request(LPHAddress.from(data.id), results[0]!, results[1]!, results[2]!, keyStorage, data.updatedAt.toInt());
  }

  /// Get a request from a stored payload in the database.
  static Future<Request?> fromStoredPayload(String id, int updatedAt, Map<String, dynamic> json) async {
    final keyStorage = await KeyStorage.fromJson(json);
    if (keyStorage == null) {
      return null;
    }
    return Request(LPHAddress.from(json["id"]), json["name"], json["display_name"], "", keyStorage, updatedAt);
  }

  /// Convert to a payload for the friends vault (on the server).
  Future<String> toStoredPayload(bool self) async {
    final reqPayload = <String, dynamic>{
      "rq": true,
      "id": id.encode(),
      "self": self,
      "name": name,
      "display_name": displayName,
    };
    reqPayload.addAll(await keyStorage.toJson());

    return jsonEncode(reqPayload);
  }

  /// Convert the request to an unknown account (for accepting the friend request).
  UnknownAccount toUnknownAccount() {
    return UnknownAccount(id, name, displayName, keyStorage.verifyKey, keyStorage.publicKey);
  }

  /// Convert a request object to the equivalent database object.
  Future<RequestData> entity(bool self) async => RequestData(
    id: id.encode(),
    name: await dbEncrypted(name),
    displayName: await dbEncrypted(displayName),
    vaultId: await dbEncrypted(vaultId),
    keys: await dbEncrypted(jsonEncode(keyStorage.toJson())),
    self: self,
    updatedAt: BigInt.from(updatedAt),
  );

  /// Copy all data from another request into this one.
  void copyFrom(Request request) {
    id = request.id;
    name = request.name;
    displayName = request.displayName;
    vaultId = request.vaultId;
    updatedAt = request.updatedAt;
    keyStorage = request.keyStorage;
  }

  /// Convert a request to a friend (for when the request is accepted)
  Friend get friend => Friend(id, name, displayName, vaultId, keyStorage, updatedAt);

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
