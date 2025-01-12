import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/chat/stored_actions_listener.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/controller/current/tasks/friend_sync_task.dart';
import 'package:chat_interface/controller/current/steps/stored_actions_step.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/logging_framework.dart';
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

  void addSentRequest(Request request) {
    requestsSent[request.id] = request;
    db.request.insertOnConflictUpdate(request.entity(true));
  }

  void addRequest(Request request) {
    requests[request.id] = request;
    db.request.insertOnConflictUpdate(request.entity(false));
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

  //* Prompt with confirm popup
  var declined = true;
  await showConfirmPopup(ConfirmWindow(
    title: "request.confirm.title".tr,
    text: "request.confirm.text".trParams(<String, String>{
      "username": "${profile.displayName} (${profile.name})",
    }),
    onConfirm: () async {
      declined = false;
      await sendFriendRequest(controller, profile!.name, profile.displayName, profile.id, profile.publicKey, profile.signatureKey, success);
    },
    onDecline: () {
      declined = true;
    },
  ));

  requestsLoading.value = !declined;
  return;
}

/// Send a friend request to an account
Future<void> sendFriendRequest(
  StatusController controller,
  String name,
  String displayName,
  LPHAddress address,
  Uint8List publicKey,
  Uint8List signatureKey,
  Function(String) success,
) async {
  if (friendsVaultRefreshing.value) {
    requestsLoading.value = false;
    return;
  }

  // Encrypt friend request
  sendLog("OWN STORED ACTION KEY: $storedActionKey");
  final payload = storedAction("fr_rq", <String, dynamic>{
    "ad": StatusController.ownAddress.encode(),
    "name": controller.name.value,
    "dname": controller.displayName.value,
    "s": encryptAsymmetricAuth(publicKey, asymmetricKeyPair.secretKey, name),
    "pub": packagePublicKey(asymmetricKeyPair.publicKey),
    "sg": packagePublicKey(signatureKeyPair.publicKey),
    "pf": packageSymmetricKey(profileKey),
    "sa": storedActionKey,
  });

  // Send stored action
  final result = await sendStoredAction(address, publicKey, payload);
  if (result != null) {
    showErrorPopup("error", result);
    requestsLoading.value = false;
    return;
  }

  // Accept friend request if there is one from the other user
  final requestController = Get.find<RequestController>();
  final requestSent = requestController.requests[address];
  if (requestSent != null) {
    final result = await Get.find<FriendController>().addFromRequest(requestSent);
    if (result) {
      await requestController.deleteRequest(requestSent);
    } else {
      showErrorPopup("error", "requests.error".tr);
    }
    success("request.accepted");
  } else {
    // Save friend request in own vault
    var request = Request(address, name, displayName, "", KeyStorage(publicKey, signatureKey, profileKey, ""), DateTime.now().millisecondsSinceEpoch);
    final vaultId = await FriendsVault.store(
      request.toStoredPayload(true),
      errorPopup: true,
      prefix: "request",
    );

    if (vaultId == null) {
      requestsLoading.value = false;
      return;
    }

    // This had me in a mental breakdown, but then I ended up fixing it in 10 minutes LMFAO
    request.vaultId = vaultId;

    RequestController requestController = Get.find();
    requestController.addSentRequest(request);
    success("request.sent");
  }

  requestsLoading.value = false;
  return;
}

class Request {
  final LPHAddress id;
  String name;
  String displayName;
  String vaultId;
  int updatedAt;
  final KeyStorage keyStorage;
  final loading = false.obs;

  Request(this.id, this.name, this.displayName, this.vaultId, this.keyStorage, this.updatedAt);

  /// Get a request from the database object
  factory Request.fromEntity(RequestData data) {
    return Request(
      LPHAddress.from(data.id),
      fromDbEncrypted(data.name),
      fromDbEncrypted(data.displayName),
      fromDbEncrypted(data.vaultId),
      KeyStorage.fromJson(jsonDecode(fromDbEncrypted(data.keys))),
      data.updatedAt.toInt(),
    );
  }

  /// Get a request from a stored payload in the database
  factory Request.fromStoredPayload(Map<String, dynamic> json, int updatedAt) {
    return Request(
      LPHAddress.from(json["id"]),
      json["name"],
      json["display_name"],
      "",
      KeyStorage.fromJson(json),
      updatedAt,
    );
  }

  // Convert to a payload for the friends vault (on the server)
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

  /// Convert a request object to the equivalent database object
  RequestData entity(bool self) => RequestData(
        id: id.encode(),
        name: dbEncrypted(name),
        displayName: dbEncrypted(displayName),
        vaultId: dbEncrypted(vaultId),
        keys: dbEncrypted(jsonEncode(keyStorage.toJson())),
        self: self,
        updatedAt: BigInt.from(updatedAt),
      );

  /// Convert a request to a friend (for when the request is accepted)
  Friend get friend => Friend(id, name, displayName, vaultId, keyStorage, updatedAt);

  // Accept friend request
  void accept(Function(String) success) {
    // Send a request to the same guy (this thing will detect that the request already exist and then add him, this avoids code duplication)
    sendFriendRequest(Get.find<StatusController>(), name, displayName, id, keyStorage.publicKey, keyStorage.signatureKey, (msg) async {
      success(msg);
    });
  }

  // Decline friend request
  Future<void> ignore() async {
    // Delete from friends vault
    await FriendsVault.remove(vaultId);

    // Delete from requests
    final requestController = Get.find<RequestController>();
    await requestController.deleteRequest(this);
  }

  // Cancel friend request (only for sent requests)
  Future<void> cancel() async {
    // Delete from friends vault
    await FriendsVault.remove(vaultId);

    // Delete from sent requests
    final requestController = Get.find<RequestController>();
    await requestController.deleteSentRequest(this);
  }

  void save(bool self) {
    db.request.insertOnConflictUpdate(entity(self));
  }
}
