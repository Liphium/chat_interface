part of 'friends_page.dart';

void openConversation(RxBool loading, String name, List<int> friends) {
  loading.value = true;

  // Create encrypted payloads for friends
  var map = <int, String>{};
  for(var friend in friends) {
  }

  // Send request
  connector.sendAction(Message("conv_open", <String, dynamic>{
    "members": friends,
    "data": name,
  }), waiter: () => loading.value = false);
}