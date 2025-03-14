part of 'stored_actions_listener.dart';

Future<bool> deleteStoredAction(String id) async {
  final json = await postAuthorizedJSON("/account/stored_actions/delete", {"id": id});

  if (!json["success"]) {
    sendLog("couldn't delete stored action: ${json["error"]}");
    return false;
  }

  return true;
}

/// Send an authenticated stored action to a friend.
///
/// Returns an error if there was one.
Future<String?> sendAuthenticatedStoredAction(Friend friend, Map<String, dynamic> payload) async {
  // Set the sender
  payload["s"] = StatusController.ownAddress.encode();

  // Make sure the server is trusted
  if (!await TrustedLinkHelper.askToAddIfNotAdded(friend.id.server)) {
    return "error.untrusted_server".trParams({"domain": friend.id.server});
  }

  // Send the authenticated stored action
  final keys = await friend.getKeys();
  final json = await postAddress(friend.id.server, "/account/stored_actions/send_auth", <String, dynamic>{
    "account": friend.id.id,
    // actual data (safe from replay attacks thanks to sequence numbers and the sender saving the last receive time)
    "payload": AsymmetricSequencedInfo.builder(jsonEncode(payload), DateTime.now().millisecondsSinceEpoch).finish(keys.publicKey),
    "key": keys.storedActionKey,
  });
  if (!json["success"]) {
    return json["error"];
  }

  return null;
}

/// Send a stored action to someone using their address (returns null when successful)
Future<String?> sendStoredAction(LPHAddress address, Uint8List publicKey, String payload) async {
  // Send stored action
  final json = await postAddress(address.server, "/account/stored_actions/send", <String, dynamic>{
    "account": address.id,
    "payload": createPayload(payload, publicKey),
  });

  // Make sure the request was successful
  if (!json["success"]) {
    sendLog("couldn't send stored action: ${json["error"]}");
    return json["error"];
  }

  return null;
}

String createPayload(String payload, Uint8List publicKey) {
  return encryptAsymmetricAnonymous(publicKey, payload);
}
