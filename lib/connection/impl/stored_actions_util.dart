part of 'stored_actions_listener.dart';

Future<bool> deleteStoredAction(String id) async {
  final json = await postAuthorizedJSON("/account/stored_actions/delete", {"id": id});

  if (!json["success"]) {
    sendLog("couldn't delete stored action: ${json["error"]}");
    return false;
  }

  return true;
}

Future<bool> sendAuthenticatedStoredAction(Friend friend, Map<String, dynamic> payload) async {
  // Set the sender
  payload["s"] = StatusController.ownAccountId;

  // Send stored action
  final json = await postJSON("/account/stored_actions/send_auth", <String, dynamic>{
    "account": friend.id,
    // actual data (safe from replay attacks thanks to sequence numbers)
    "payload": SequencedInfo.builder(jsonEncode(payload), DateTime.now().millisecondsSinceEpoch).finish(friend.keyStorage.publicKey),
    "key": friend.keyStorage.storedActionKey,
  });

  if (!json["success"]) {
    sendLog("couldn't send stored action: ${json["error"]}");
    return false;
  }

  return true;
}

Future<bool> sendStoredAction(String account, Uint8List publicKey, String payload) async {
  // Send stored action
  final json = await postAuthorizedJSON("/account/stored_actions/send", <String, dynamic>{
    "account": account,
    "payload": createPayload(payload, publicKey),
  });

  if (!json["success"]) {
    sendLog("couldn't send stored action: ${json["error"]}");
    return false;
  }

  return true;
}

String createPayload(String payload, Uint8List publicKey) {
  return encryptAsymmetricAnonymous(publicKey, payload);
}
