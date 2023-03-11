
import 'package:chat_interface/connection/connection.dart';

import 'friend_request_listener.dart' as requests;

void setupFriendListeners() {
  connector.listen("fr_rq:l", requests.friendRequest);
}