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

  // TODO: Implement  

  return true;
}