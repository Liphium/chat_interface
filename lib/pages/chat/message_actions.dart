part of 'message_feed.dart';

void sendMessage(RxBool loading, int conversation, String message, Function() callback) {
  loading.value = true;

  connector.sendAction(messaging.Message("conv_msg_create", <String, dynamic>{
    "conversation": conversation,
    "data": message
  }), handler: (event) {
    callback.call();
    if(event.data["success"]) return;

    String message = "conv_msg_create.${event.data["status"]}";
    if(event.data["message"] == "server.error") {
      message = "server.error";
    }

    showMessage(SnackbarType.error, message.tr);
  });
}