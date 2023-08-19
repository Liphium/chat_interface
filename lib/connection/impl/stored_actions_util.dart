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
  final res = await postRqAuth("/account/stored_actions/send_auth", <String, dynamic>{
    "account": friend.id,
    "payload": payload,
    "key": friend.keyStorage.storedActionKey,
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