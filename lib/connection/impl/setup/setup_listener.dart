
import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;
import 'package:chat_interface/main.dart';
import '../friends/status_listener.dart';

void setupSetupListeners() {

  //* New device
  connector.listen("setup_device", (event) {
    logger.i("New device: ${event.data["device"]}");
  });

  //* New status
  connector.listen("setup_st", setupStatusListener);

  //* Setup finished
  connector.listen("setup_fin", (event) {
    logger.i("Setup finished");

    // Update status
    connector.sendAction(msg.Message("acc_on", <String, dynamic>{}));
  });
}