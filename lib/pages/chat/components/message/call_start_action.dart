part of 'message_feed.dart';

void startCall(RxBool loading, int conversation) {
  loading.value = true;
  final controller = Get.find<CallController>();

  if(controller.livekit.value) {

    loading.value = false;
    controller.leaveCall();
    showMessage(SnackbarType.error, "left.call");
    return;
  } else if(controller.conversation.value == conversation) {

    loading.value = false;
    showMessage(SnackbarType.error, "already.calling");
    return;
  }

  connector.sendAction(messaging.Message("c_s", <String, dynamic>{
    "id": conversation,
  }), handler: (event) {
    loading.value = false;

    if(!event.data["success"]) {
      showMessage(SnackbarType.error, event.data["message"]);
      return;
    }

    if(event.data["call"]) {
      Get.find<CallController>().joinWithLivekit(conversation, event.data["token"]);
    } else {
      Get.find<CallController>().openWithoutLivekit(conversation);

      // Send call message
      sendActualMessage(loading, conversation, "call", event.data["token"], "", () => loading.value = false);
    }

  });
}