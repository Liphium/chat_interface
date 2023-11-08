import 'package:get/get.dart';

class ChatPageTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {

    //* English US
    'en_US': {
      // Profile
      'status.0': 'Offline',
      'status.1': 'Online',
      'status.2': 'Away',
      'status.3': 'Busy',
      'status.message': 'Status message',
      'status.message.add': 'Add a status message',
      'profile.settings': 'Settings',
      'profile.theme.dark': 'Dark theme',
      'profile.theme.light': 'Light theme',
      'profile.test': "Test something (DON'T CLICK)",

      // Friends
      'friends': 'Friends',
      'friends.placeholder': 'Search friends',
      'friends.remove': 'Remove friend',
      'friends.add': 'Add friend',
      'friends.message': 'Start direct message',
      'friends.invite_to_space': 'Invite to current space',

      // Conversations
      'conversations.placeholder': 'Search (. for hidden ones)',
      'conversations.create': 'Create conversation',
      'conversations.name': 'Conversation name',
      'chat.message': 'Say something',

      // Sharing
      'sharing.placeholder': 'Search shared content',
      'join.space': 'Join space',
      'join.space.popup': 'Some people click this on accident, so do you really want to join this space?',
    },

    //* German
    'de_DE': {
      // Profile
      'status.0': 'Offline',
      'status.1': 'Online',
      'status.2': 'Abwesend',
      'status.3': 'Beschäftigt',
      'status.message': 'Status',
      'status.message.add': 'Status hinzufügen',
      'profile.settings': 'Einstellungen',
      'profile.theme.dark': 'Dunkles Design',
      'profile.theme.light': 'Helles Design',
      'profile.test': "Teste etwas (NICHT KLICKEN)",

      // Friends
      'friends': 'Freunde',
      'friends.placeholder': 'Freunde durchsuchen',
      'friends.remove': 'Freund entfernen',
      'friends.add': 'Freund hinzufügen',
      'friends.message': 'Direktnachricht starten',
      'friends.invite_to_space': 'Zum Space einladen',

      // Conversations
      'conversations.placeholder': 'Suche (. für versteckte)',
      'conversations.create': 'Chat erstellen',
      'conversations.name': 'Gruppenname',
      'chat.message': 'Sag etwas',

      // Sharing
      'sharing.placeholder': 'Geteilte Inhalte durchsuchen',
      'join.space': 'Space beitreten',
      'join.space.popup': 'Manche klicken darauf ausversehen, also willst du wirklich diesem Space beitreten?',
    }
  };
}