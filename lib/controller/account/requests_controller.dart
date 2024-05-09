import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/account/stored_actions_setup.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/standards/unicode_string.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

import 'friend_controller.dart';

class RequestController extends GetxController {
  final requestsSent = <Request>[].obs;
  final requests = <Request>[].obs;

  void reset() {
    requests.clear();
  }

  Future<bool> loadRequests() async {
    for (RequestData data in await db.request.select().get()) {
      if (data.self) {
        requestsSent.add(Request.fromEntity(data));
      } else {
        requests.add(Request.fromEntity(data));
      }
    }

    return true;
  }

  void addSentRequest(Request request) {
    requestsSent.add(request);
    db.request.insertOnConflictUpdate(request.entity(true));
  }

  void addRequest(Request request) {
    requests.add(request);
    db.request.insertOnConflictUpdate(request.entity(false));
  }

  Future<bool> deleteSentRequest(Request request, {removal = true}) async {
    if (removal) {
      requestsSent.remove(request);
    }
    await db.request.deleteWhere((tbl) => tbl.id.equals(request.id));
    return true;
  }

  Future<bool> deleteRequest(Request request, {removal = true}) async {
    if (removal) {
      requests.remove(request);
    }
    await db.request.deleteWhere((tbl) => tbl.id.equals(request.id));
    return true;
  }
}

final requestsLoading = false.obs;

/// Send a new friend request to an account by name
void newFriendRequest(String name, Function(String) success) async {
  requestsLoading.value = true;

  final controller = Get.find<StatusController>();
  if (name == controller.name.value) {
    showErrorPopup("request.self", "request.self.text");
    requestsLoading.value = false;
    return;
  }

  // Get public key and id of the user
  var json = await postAuthorizedJSON("/account/stored_actions/details", <String, dynamic>{
    "username": name,
  });
  if (!json["success"]) {
    showErrorPopup("request.${json["error"]}", "request.${json["error"]}.text");
    requestsLoading.value = false;
    return;
  }

  final id = json["account"];
  final publicKey = unpackagePublicKey(json["key"]);
  final signatureKey = unpackagePublicKey(json["sg"]);

  //* Prompt with confirm popup
  var declined = true;
  await showConfirmPopup(ConfirmWindow(
    title: "request.confirm.title".tr,
    text: "request.confirm.text".trParams(<String, String>{
      "username": "${json["display_name"]} ($name)",
    }),
    onConfirm: () async {
      declined = false;
      sendFriendRequest(controller, name, UTFString.untransform(json["display_name"]), id, publicKey, signatureKey, success);
    },
    onDecline: () {
      declined = true;
    },
  ));

  requestsLoading.value = !declined;
  return;
}

/// Send a friend request to an account
void sendFriendRequest(
    StatusController controller, String name, UTFString displayName, String id, Uint8List publicKey, Uint8List signatureKey, Function(String) success) async {
  // Encrypt friend request
  sendLog("OWN STORED ACTION KEY: $storedActionKey");
  final payload = storedAction("fr_rq", <String, dynamic>{
    "name": controller.name.value,
    "dname": controller.displayName.value.text,
    "s": encryptAsymmetricAuth(publicKey, asymmetricKeyPair.secretKey, name),
    "pf": packageSymmetricKey(profileKey),
    "sa": storedActionKey,
  });

  // Send stored action
  final result = await sendStoredAction(id, publicKey, payload);
  if (!result) {
    showErrorPopup(Constants.unknownError.tr, Constants.unknownErrorText.tr);
    requestsLoading.value = false;
    return;
  }

  // Accept friend request if there is one from the other user
  final requestController = Get.find<RequestController>();
  final requestSent = requestController.requests.firstWhere((element) => element.id == id, orElse: () => Request.mock("hi"));
  if (requestSent.id != "hi") {
    requestController.deleteRequest(requestSent);
    await Get.find<FriendController>().addFromRequest(requestSent);
    success("request.accepted");
  } else {
    // Save friend request in own vault
    var request = Request(id, name, displayName, "", KeyStorage(publicKey, signatureKey, profileKey, ""), DateTime.now().millisecondsSinceEpoch);
    final vaultId = await storeInFriendsVault(request.toStoredPayload(true), errorPopup: true, prefix: "request");

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
  final String id;
  final String name;
  final UTFString displayName;
  String vaultId;
  int updatedAt;
  final KeyStorage keyStorage;
  final loading = false.obs;

  Request(this.id, this.name, this.displayName, this.vaultId, this.keyStorage, this.updatedAt);

  /// Type to mock a request in case of orElse: statements. DON'T USE FOR TESTING
  factory Request.mock(String id) {
    return Request(id, "", UTFString(""), "", KeyStorage.empty(), 0);
  }

  /// Get a request from the database object
  factory Request.fromEntity(RequestData data) {
    return Request(
      data.id,
      data.name,
      UTFString.untransform(data.displayName),
      data.vaultId,
      KeyStorage.fromJson(jsonDecode(data.keys)),
      data.updatedAt.toInt(),
    );
  }

  /// Get a request from a stored payload in the database
  factory Request.fromStoredPayload(Map<String, dynamic> json, int updatedAt) {
    return Request(
      json["id"],
      json["name"],
      UTFString.untransform(json["display_name"]),
      "",
      KeyStorage.fromJson(json),
      updatedAt,
    );
  }

  // Convert to a payload for the friends vault (on the server)
  String toStoredPayload(bool self) {
    final reqPayload = <String, dynamic>{
      "rq": true,
      "id": id,
      "self": self,
      "name": name,
      "display_name": displayName.transform(),
    };
    reqPayload.addAll(keyStorage.toJson());

    return jsonEncode(reqPayload);
  }

  /// Convert a request object to the equivalent database object
  RequestData entity(bool self) => RequestData(
        id: id,
        name: name,
        displayName: displayName.transform(),
        vaultId: vaultId,
        keys: jsonEncode(keyStorage.toJson()),
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
  void ignore() async {
    // Delete from friends vault
    await removeFromFriendsVault(vaultId);

    // Delete from requests
    final requestController = Get.find<RequestController>();
    requestController.deleteRequest(this);
  }

  // Cancel friend request (only for sent requests)
  void cancel() async {
    // Delete from friends vault
    await removeFromFriendsVault(vaultId);

    // Delete from sent requests
    final requestController = Get.find<RequestController>();
    requestController.deleteSentRequest(this);
  }

  void save(bool self) {
    db.request.insertOnConflictUpdate(entity(self));
  }
}
