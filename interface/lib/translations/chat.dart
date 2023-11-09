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
      'profile.friends': 'Friends',
      'profile.files': 'Files',
      'profile.test': "Test something (DON'T CLICK)",

      // Friends
      'friends': 'Friends',
      'friends.placeholder': 'Search friends (type name to add)',
      'friends.remove': 'Remove friend',
      'friend.removed': 'You removed this person.',
      'friends.add': 'Add friend',
      'friends.message': 'Start direct message',
      'friends.invite_to_space': 'Invite to current space',
      'friends.requests_sent': 'Requests sent',
      'friends.requests': 'Requests',

      // Conversations
      'conversations.placeholder': 'Search (. for hidden ones)',
      'conversations.create': 'Create conversation',
      'conversations.name': 'Conversation name',
      'chat.message': 'Say something',

      // Spaces
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
      'profile.friends': 'Freunde',
      'profile.files': 'Dateien',
      'profile.test': "Teste etwas (NICHT KLICKEN)",

      // Friends
      'friends': 'Freunde',
      'friends.placeholder': 'Freunde durchsuchen (auch hinzufügen)',
      'friends.remove': 'Freund entfernen',
      'friend.removed': 'Du hast diese Person entfernt.',
      'friends.add': 'Freund hinzufügen',
      'friends.message': 'Direktnachricht starten',
      'friends.invite_to_space': 'Zum Space einladen',
      'friends.requests_sent': 'Gesendete Anfragen',
      'friends.requests': 'Anfragen',

      // Conversations
      'conversations.placeholder': 'Suche (. für versteckte)',
      'conversations.create': 'Chat erstellen',
      'conversations.name': 'Gruppenname',
      'chat.message': 'Sag etwas',

      // Spaces
      'join.space': 'Space beitreten',
      'join.space.popup': 'Manche klicken darauf ausversehen, also willst du wirklich diesem Space beitreten?',
    }
  };
}