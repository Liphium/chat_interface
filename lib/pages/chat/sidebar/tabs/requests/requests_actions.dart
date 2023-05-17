part of 'requests_page.dart';

void _addButton(String input, RxBool loading, {Function(String)? success}) async {
  loading.value = true;
  
  // Get username and tag from input
  List<String> values = input.split('#');
  if (values.length != 2) {

    // Show error
    showMessage(SnackbarType.error, "fr_rq.tag.needed".tr);
    loading.value = false;
    return;
  }

  // Sign name of the user
  final signedName = sign(asymmetricKeyPair.privateKey, values[0]);

  // Send friend request
  connector.sendAction(Message("fr_rq", <String, dynamic>{
    "username": values[0],
    "tag": values[1],
    "signature": signedName,
  }), waiter: () => loading.value = false,);
}

void denyFriendRequest(String id, {RxBool? loading}) {

  loading?.value = true;

  connector.sendAction(Message("fr_rq_deny", <String, dynamic>{
    "id": id,
  }), waiter: () => loading?.value = false,);
}