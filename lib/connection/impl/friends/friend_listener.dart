
import 'package:chat_interface/connection/connection.dart';

import 'friend_request_listener.dart' as requests;
import 'status_listener.dart';

void setupFriendListeners() {
  connector.listen("fr_rq:l", requests.friendRequest);
  connector.listen("fr_rq", requests.friendRequestStatus);
  
  // Status
  connector.listen("fr_st", friendStatusListener);
}