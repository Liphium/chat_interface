part of 'friends_page.dart';

void openConversation(RxBool loading, String name, List<int> friends) {
  loading.value = true;

  // Send request
  connector.sendAction(Message("conv_open", <String, dynamic>{
    "members": friends,
    "data": name,
  }), waiter: () => loading.value = false);
}