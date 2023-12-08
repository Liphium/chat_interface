part of 'stored_actions_listener.dart';

Future<bool> deleteStoredAction(String id) async {
  
  final res = await postRqAuthorized("/account/stored_actions/delete", {
    "id": id
  });

  if(res.statusCode != 200) {
    sendLog("couldn't delete stored action: invalid request");
    return false;
  }

  final json = jsonDecode(res.body);
  if(!json["success"]) {
    sendLog("couldn't delete stored action: ${json["error"]}");
    return false;
  }

  return true;
}

Future<bool> sendAuthenticatedStoredAction(Friend friend, String payload) async {

  // Send stored action
  final res = await postRq("/account/stored_actions/send_auth", <String, dynamic>{
    "account": friend.id,
    "payload": createPayload(payload, friend.keyStorage.publicKey),
    "key": friend.keyStorage.storedActionKey,
  });

  if(res.statusCode != 200) {
    sendLog("couldn't send stored action: invalid request");
    return false;
  }

  final json = jsonDecode(res.body);
  if(!json["success"]) {
    sendLog("couldn't send stored action: ${json["error"]}");
    return false;
  }

  return true;
}

Future<bool> sendStoredAction(String account, Uint8List publicKey, String payload) async {

  // Send stored action
  final res = await postRqAuth("/account/stored_actions/send", <String, dynamic>{
    "account": account,
    "payload": createPayload(payload, publicKey),
  }, randomRemoteID());

  if(res.statusCode != 200) {
    sendLog("couldn't send stored action: invalid request");
    return false;
  }

  final json = jsonDecode(res.body);
  if(!json["success"]) {
    sendLog("couldn't send stored action: ${json["error"]}");
    return false;
  }

  return true;
}

String createPayload(String payload, Uint8List publicKey) {
  return encryptAsymmetricAnonymous(publicKey, payload);
}