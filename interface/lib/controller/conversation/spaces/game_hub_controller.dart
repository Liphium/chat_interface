import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/games/kanagrid_engine.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';

class GameHubController extends GetxController {

  // All games (mainly for UI)
  final games = {
    "chess": Game("chess", "Chess", "Play chess with your friends", "It's very complicated yk", "assets/img/chess.jpg"),
  };

  // Current sessions on the server
  final sessions = <String, GameSession>{}.obs;

  // Current game session
  Engine? engine;
  final sessionLoading = false.obs;

  void newSession(String game) {
    sessionLoading.value = true;

    spaceConnector.sendAction(Message("game_init", {
      "game": game
    }), handler: (event) {
      sessionLoading.value = false;
      
      if(event.data["success"]) {
        sendLog("Game session created");
        final session = GameSession(event.data["session"], game);
        engine = KanagridEngine(session);
      }

    },);

  }

  void leaveCall() {
    engine = null;
    sessions.clear();
  }

}

// Class for game data (mainly for UI)
class Game {
  final String serverId; // Id to start the game on the space-node
  final String coverImageAsset;
  final String name;
  final String shortDescription, description;

  Game(this.serverId, this.name, this.shortDescription, this.description, this.coverImageAsset);
}

// Abstract class for game engines (to be implemented by each game)
abstract class Engine {

  final GameSession session;

  Engine(this.session);

  void receiveEvent(String event, dynamic data);

  void sendEvent(String event, dynamic data) {
    spaceConnector.sendAction(Message("game_event", <String, dynamic>{
      "session": session.id,
      "name": event,
      "data": data
    }));
  }
}

// The actual game session from the server
class GameSession {
  final String id;
  final String game;
  final members = <String>[].obs;

  GameSession(this.id, this.game);

}