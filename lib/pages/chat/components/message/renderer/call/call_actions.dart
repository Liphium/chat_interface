part of 'message_call_renderer.dart';

void joinCall(RxBool loading, String conversation, String token) {
  loading.value = true;

  connector.sendAction(msg.Message("c_j", <String, dynamic>{
    "id": conversation,
    "token": token,
  }), handler: (event) {
    loading.value = false;

    if(!event.data["success"]) {
      showMessage(SnackbarType.error, event.data["message"]);
      return;
    }

    Get.find<CallController>().joinWithLivekit(conversation, event.data["token"]);
  },);

}