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
  connector.sendActionAndListen(Message("fr_rq", <String, dynamic>{
    "username": values[0],
    "tag": values[1]
  }), (event) {  
    
    if(!event.data["success"]) {
      showMessage(SnackbarType.error, "fr_rq.${event.data["message"]}".tr);
    } else {

      if(event.data["message"] == "accepted") {
        int friendId = event.data["id"] as int;

        Get.find<FriendController>().friends.add(Friend(friendId, event.data["name"], event.data["tag"]));
        Get.find<RequestController>().requests.removeWhere((element) => element.id == friendId);
      }

      showMessage(SnackbarType.success, "fr_rq.${event.data["message"]}".trParams({"name": values[0]}));
      success?.call(event.data["message"] as String);
    }
    loading.value = false;
  });
}