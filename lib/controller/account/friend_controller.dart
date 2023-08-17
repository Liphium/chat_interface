import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

part 'key_container.dart';
part 'friends_vault.dart';

class FriendController extends GetxController {
  
  final friends = <String, Friend>{}.obs;

  Future<bool> loadFriends() async {
    for(FriendData data in await db.friend.select().get()) {
      friends[data.id] = Friend.fromEntity(data);
    }

    return true;
  }

  void reset() {
    friends.clear();
  }

  // Add friend (also sends data to server vault)
  Future<bool> addFromRequest(Request request) async {

    // Remove request from server
    if(!(await removeFromFriendsVault(request.vaultId))) {
      add(request.friend); // Add regardless cause restart of the app fixes not being able to remove the guy
      return false;
    }

    // Remove stored action from server
    await deleteStoredAction(request.storedActionId);
    
    // Add friend to vault
    final id = await storeInFriendsVault(request.friend.toStoredPayload());

    if(id == null) {
      add(request.friend); // probably already in the vault (from other device)
      return false;
    }

    // Add friend to database with vault id
    request.vaultId = id;
    add(request.friend);

    // Remove from requests controller
    Get.find<RequestController>().deleteSentRequest(request);

    return true;
  }

  void add(Friend friend) {
    friends[friend.id] = friend;
    db.friend.insertOnConflictUpdate(friend.entity());
  }

  void remove(Friend friend) {
    friends.remove(friend.id);
    db.friend.deleteWhere((tbl) => tbl.id.equals(friend.id));
  }
}

class Friend {
  String id;
  String name;
  String tag;
  String vaultId;
  KeyStorage keyStorage;
  var status = "-".obs;
  final statusType = 0.obs;

  /// Loading state for open conversation buttons
  final openConversationLoading = false.obs;

  Friend(this.id, this.name, this.tag, this.vaultId, this.keyStorage);

  Friend.system() : id = "system", name = "System", tag = "fjc", vaultId = "", keyStorage = KeyStorage.empty();
  Friend.me()
        : id = '',
          name = '',
          tag = '',
          vaultId = '',
          keyStorage = KeyStorage.empty() {
    final StatusController controller = Get.find();
    id = controller.id.value;
    name = controller.name.value;
    tag = controller.tag.value;
  }
  Friend.unknown(this.id) 
        : name = 'fj-$id',
          tag = 'tag',
          vaultId = '',
          keyStorage = KeyStorage.empty();

  Friend.fromEntity(FriendData data)
        : id = data.id,
          name = data.name,
          tag = data.tag,
          vaultId = data.vaultId,
          keyStorage = KeyStorage.fromJson(jsonDecode(data.keys));

  Friend.fromStoredPayload(Map<String, dynamic> json) :
        id = json["id"],
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

  //* Remove friend
  Future<bool> remove(RxBool loading) async {
    //loading.value = true;

    await removeFromFriendsVault(vaultId);
    db.friend.deleteWhere((tbl) => tbl.id.equals(id));
    Get.find<FriendController>().friends.remove(id);

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
  );
}