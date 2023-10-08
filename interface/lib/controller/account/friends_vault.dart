part of 'friend_controller.dart';

// Store friend in vault (returns id of the friend in the vault if successful)
Future<String?> storeInFriendsVault(String data, {errorPopup = false, prefix = ""}) async {

  final hash = hashSha(data);
  final payload = encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, data);

  final res = await postRqAuthorized("/account/friends/add", <String, dynamic>{
    "hash": hash,
    "payload": payload,
  });

  if(res.statusCode != 200) {
    if(errorPopup) {
      showErrorPopup("error.network", "error.network.text");
    }
    return null;
  }

  final json = jsonDecode(res.body);
  if(!json["success"]) {
    if(errorPopup) {
      showErrorPopup("$prefix.${json["error"]}", "$prefix.${json["error"]}.text");
    }
    return null;
  }

  return json["id"];
}

// Remove friend from vault (returns true if successful)
Future<bool> removeFromFriendsVault(String id, {errorPopup = false}) async {
  
    final res = await postRqAuthorized("/account/friends/remove", <String, dynamic>{
      "id": id,
    });
  
    if(res.statusCode != 200) {
      return false;
    }
  
    final json = jsonDecode(res.body);
    sendLog(json);
    sendLog(id);
    return json["success"] as bool;
  }