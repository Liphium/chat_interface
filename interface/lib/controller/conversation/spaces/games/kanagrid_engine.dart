import 'package:chat_interface/controller/conversation/spaces/game_hub_controller.dart';

class KanagridEngine extends Engine {
  
    KanagridEngine(GameSession session) : super(session);
  
    @override
    void receiveEvent(String event, dynamic data) {
      print("Received event $event with data $data");
    }
}