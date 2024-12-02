import 'package:get/get.dart';

class SpacesTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
          // General
          'spaces.already_calling': 'You are already in a Space. Leave it if you want to open a new one.',
          'spaces.calling': 'is calling..',
          'spaces.sharing_other_device': 'Sharing with friends',
          'spaces.count': '@count members',
          'spaces.toggle_people': 'Toggle showing people',
          'spaces.tab.space': 'Space',
          'spaces.tab.table': 'Tabletop',

          // Welcome screen
          'spaces.welcome': 'Welcome to this Space!',
          'spaces.welcome.desc':
              'Spaces is Liphium\'s version of a temporary gathering where you can do all kinds of things with your friends. Click the arrow in the bottom right to open the chat. Click "Tabletop" in the tab selector right above this text to enjoy our Tabletop emulator for playing card games. Have fun!',

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
          'tabletop.object.deck.incompatible':
              'This deck is incompatible with the newest version of the standard. Please create it again and try again.',
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
