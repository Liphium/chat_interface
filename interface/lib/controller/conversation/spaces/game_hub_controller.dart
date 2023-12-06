import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/games/wordgrid_engine.dart';
import 'package:chat_interface/pages/spaces/gamemode/lobby_view.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameHubController extends GetxController {

  // All games (mainly for UI)
  final games = {
    "wordgrid": Game("wordgrid", "Word grid", "Play chess with your friends", "It's very complicated yk", "assets/img/chess.jpg"),
  };

  // Current sessions on the server
  final sessions = <String, GameSession>{}.obs;

  // Current game session
  final engine = Rx<Engine?>(null);
  final sessionLoading = false.obs;

  void newSession(String game) {
    sessionLoading.value = true;

    spaceConnector.sendAction(Message("game_init", {
      "game": game
    }), handler: (event) {
      sessionLoading.value = false;
      
      if(event.data["success"]) {
        sendLog("Game session created");
        final session = GameSession(event.data["session"], game, event.data["min"], event.data["max"]);
        engine.value = WordgridEngine(session.id);
      }

    },);

  }

  void leaveCall() {
    engine.value = null;
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

  final String sessionId;

  Engine(this.sessionId);

  Widget build(BuildContext context);

  Widget render(BuildContext context) {
    return Obx(() {
      final session = Get.find<GameHubController>().sessions[sessionId]!;
      if(session.gameState.value == gameStateLobby) {
        return LobbyView(session: session);
      } else {
        return build(context);
      }
    });
  }

  void receiveEvent(String event, dynamic data);

  void sendEvent(String event, dynamic data) {
    spaceConnector.sendAction(Message("game_event", <String, dynamic>{
      "session": sessionId,
      "name": event,
      "data": data
    }));
  }
}

const gameStateLobby = 1;

// The actual game session from the server
class GameSession {
  final String id;
  final String game;
  final int minPlayers;
  final int maxPlayers;

  final gameState = gameStateLobby.obs;
  final members = <String>[].obs;
  var loading = false;

  GameSession(this.id, this.game, this.minPlayers, this.maxPlayers);

  void start() {
    loading = true;
    spaceConnector.sendAction(Message("game_start", {
      "session": id,
    }), handler: (event) {
      loading = false;
      if(!event.data["success"]) {
        showErrorPopup("error".tr, event.data["message"].toString().tr);
      }
    });
  }

}