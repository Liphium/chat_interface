part of 'friends_page.dart';

void openConversation(RxBool loading, String name, List<int> friends) {
  loading.value = true;

  // Generate secure key
  var key = randomAESKey();

  // Create encrypted payloads for friends
  var keys = <String, String>{};
  FriendController controller = Get.find();

  for(var friend in friends) {
    keys[friend.toString()] = encryptRSA64(key, controller.friends[friend]!.publicKey);
  }

  StatusController status = Get.find();
  keys[status.id.value.toString()] = encryptRSA64(key, asymmetricKeyPair.publicKey);

  // Send request
  connector.sendAction(Message("conv_open", <String, dynamic>{
    "members": friends,
    "data": encryptAES(name, key).base64,
    "keys": jsonEncode(keys)
  }), waiter: () => loading.value = false);
}