
import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/conversation/call/call_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';

void setupCallListeners() {

  connector.listen("c_s:l", _joinCall);
}

// Action c_s:l
void _joinCall(Event openEvent) {

  sendLog("JOINING CALL");

  // Join call
  connector.sendAction(Message("c_s", <String, dynamic>{
    "id": openEvent.data["conv"],
  }), handler: (event) {

    if(!event.data["success"]) {
      showMessage(SnackbarType.error, "c_o.${event.data["message"]}");
      return;
    }

    // Check if call token was provided
    if(!event.data["call"]) {
      return;
    }

    // Connect to livekit
    Get.find<CallController>().joinWithLivekit(openEvent.data["conv"], event.data["token"]);
  });
}