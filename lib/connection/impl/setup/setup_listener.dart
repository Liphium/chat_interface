
import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/main.dart';
import '../friends/status_listener.dart';

void setupSetupListeners() {

  //* New status
  connector.listen("setup_st", setupStatusListener);

  //* Setup finished
  connector.listen("setup_fin", (event) {
    logger.i("Setup finished");
  });
}