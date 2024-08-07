import 'package:get/get.dart';

class SpacesTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
          // General
          'spaces.calling': 'is calling..',
          'spaces.sharing_other_device': 'Sharing with friends',
          'spaces.count': '@count members',
          'spaces.toggle_people': 'Toggle showing people',

          // Game hub
          'game.lobby': 'Ready to start. (@count/@max)',
          'game.lobby_waiting': 'Waiting for more players. (@count/@min)',

          // Tabletop
          'tabletop.object.create': 'Create object',
          'tabletop.object.deck': 'Deck',
          'tabletop.object.deck.choose': 'Choose a deck',
          'tabletop.object.deck.choose_empty': 'No decks available. You can create one in the settings.',
          'tabletop.match_viewport': 'Rotate to viewport',
          'tabletop.object.text': 'Text',
          'tabletop.object.text.create': 'Create text object',
          'tabletop.object.text.placeholder': 'Enter text here',
          'tabletop.object.deck.incompatible': 'This deck is incompatible with the newest version of the standard. Please create it again and try again.',
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
