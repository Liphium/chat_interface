import 'package:get/get.dart';

class SpacesTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
          // Game hub
          'game.lobby': 'Ready to start. (@count/@max)',
          'game.lobby_waiting': 'Waiting for more players. (@count/@min)',
        },

        //* German
        'de_DE': {
          /*
      // Game hub
      'game.lobby': 'Bereit zum Start. (@count/@max)',
      'game.lobby_waiting': 'Warte auf mehr Spieler. (@count/@min)',
      */
        },
      };
}
