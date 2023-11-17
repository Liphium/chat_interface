import 'package:get/get.dart';

class GameHubController extends GetxController {

  final games = [
    Game("chess", "Chess", "Play chess with your friends", "assets/img/chess.jpg"),
    Game("chess", "Chess", "Play chess with your friends", "assets/img/chess.jpg"),
    Game("chess", "Chess", "Play chess with your friends", "assets/img/chess.jpg"),
    Game("chess", "Chess", "Play chess with your friends", "assets/img/chess.jpg"),

  ];

}

class Game {
  final String serverId; // Id to start the game on the space-node
  final String coverImageAsset;
  final String name;
  final String description;

  Game(this.serverId, this.name, this.description, this.coverImageAsset);
}

class GameSession {

}