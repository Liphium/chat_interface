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

  // Send friend request
  connector.sendAction(Message("fr_rq", <String, dynamic>{
    "username": values[0],
    "tag": values[1]
  }), waiter: () => loading.value = false,);
}