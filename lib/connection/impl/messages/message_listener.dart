import 'package:chat_interface/connection/connection.dart';

import 'conversation_listener.dart';

void setupMessageListeners() {
  connector.listen("conv_open:l", conversationOpen);
  connector.listen("conv_open", conversationOpenStatus);
}