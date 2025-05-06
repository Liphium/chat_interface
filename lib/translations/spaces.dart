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
      'spaces.sidebar.chat': 'Chat',
      'spaces.sidebar.people': 'People',
      'spaces.member.not_verified': 'Identity could not be verified.',

      // Welcome screen
      'spaces.welcome': 'Welcome to this Space!',
      'spaces.welcome.desc':
          'Spaces is Liphium\'s version of a temporary gathering where you can do all kinds of things with your friends. Click the arrow in the bottom right to open the chat. Click "Tabletop" in the tab selector right above this text to enjoy our Tabletop emulator for playing card games. Have fun!',

      // Warp
      'warp.title': 'Warp',
      'warp.desc':
          'Warp is Liphium\'s way to share stuff like Minecraft servers and more. You\'ll need the server\'s port though.',
      'warp.share': 'Create a Warp',

      // Translations for the Warp creation window
      'warp.create.title': 'Create a Warp',
      'warp.create.desc':
          'When you create a Warp, that port on your system will be accessible to all people and devices in the Space. Please make sure to not share important stuff.',
      'warp.port.placeholder': '25565 (default MC port)',
      'warp.create.button': 'Share this port',
      'warp.error.port_invalid': 'A port can only be between 1024 and 65535, no higher and no lower.',
      'warp.error.port_not_used': 'This port can\'t be shared because there is no server on it.',
      'warp.error.port_already_shared': 'You are already sharing this port.',

      // Translations for currently shared Warps
      'warp.shared.title': 'Shared Warps',

      // Translations for currently connected Warps
      'warp.connected.title': 'Connected Warps',
      'warp.connected.item': '@origin > @goal',

      // Translations for Warps that are listed
      'warp.list.sharing': '@name is sharing..',
      'warp.list.empty': 'No shared Warps found.',

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

      // Space Studio
      'spaces.studio.connecting': 'Connecting to Studio..',

      // Media profiles
      'media_profile.static': 'Static',
      'media_profile.motion': 'Motion',
      'media_profile.balanced': 'Balanced',
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
