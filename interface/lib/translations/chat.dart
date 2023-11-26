import 'package:get/get.dart';

class ChatPageTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {

    //* English US
    'en_US': {

      // App
      'app.title': 'The chat app',
      'app.welcome': 'Thanks for joining me on this journey!',
      'app.build': 'Current version: @build',

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
      'friends.invite_to_space': 'Invite to current Space',
      'friends.requests_sent': 'Requests sent',
      'friends.requests': 'Requests',
      'request.sent': 'Request successfully sent!',
      'friends.empty': 'Seems like you don\'t have any friends with that name.',
      'friends.send_request': 'Now just press \'Enter\' whenever you\'re done typing. And we\'ll find your friend for you.',
      'friends.example': 'If you want to add someone, please provide their username#tag. Example: Julian#1234',

      // Conversations
      'conversations.placeholder': 'Search',
      'conversations.hidden': "Searching for something else? You can use '.' at the beginning of your query to search for hidden conversations.",
      'conversations.create': 'Create conversation',
      'conversations.name': 'Conversation name',
      'chat.message': 'Say something',
      'chat.members': '@count members',
      'chat.start_space': 'Start private Space',

      // Conversation members
      'chat.make_moderator': 'Make moderator',
      'chat.remove_moderator': 'Remove moderator',
      'chat.remove_admin': 'Remove admin',
      'chat.make_admin': 'Make admin',
      'chat.remove_member': 'Remove member',
      'chat.add_member': 'Add member',
      'chat.admin': 'Admin',
      'chat.moderator': 'Moderator',

      // Spaces
      'join.space': 'Join Space',
      'join.space.popup': 'Some people click this on accident, so do you really want to join this space?',
    },

    //* German
    'de_DE': {

      // App
      'app.title': 'The chat app',
      'app.welcome': 'Danke, dass du mich auf dieser Reise begleitest!',
      'app.build': 'Aktuelle Version: @build',

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
      'request.sent': 'Anfrage erfolgreich gesendet!',
      'friends.empty': 'Es scheint, als hättest du keine Freunde mit diesem Namen.',
      'friends.send_request': 'Drücke einfach \'Enter\', wenn du fertig bist. Und wir finden deinen Freund für dich.',
      'friends.example': 'Wenn du jemanden hinzufügen willst, gib bitte Benutzername#Tag ein. Beispiel: Julian#1234',

      // Conversations
      'conversations.placeholder': 'Suche',
      'conversations.hidden': "Suchst du nach etwas anderem? Du kannst '.' am Anfang deiner Suche hinzufügen, um nach versteckten Chats zu suchen.",
      'conversations.create': 'Chat erstellen',
      'conversations.name': 'Gruppenname',
      'chat.message': 'Sag etwas',
      'chat.members': '@count Mitglieder',
      'chat.start_space': 'Privaten Space starten',

      // Conversation members
      'chat.make_moderator': 'Zum Moderator machen',
      'chat.remove_moderator': 'Moderator entfernen',
      'chat.remove_admin': 'Admin entfernen',
      'chat.make_admin': 'Zum Admin machen',
      'chat.remove_member': 'Mitglied entfernen',
      'chat.add_member': 'Mitglied hinzufügen',
      'chat.admin': 'Admin',
      'chat.moderator': 'Moderator',

      // Spaces
      'join.space': 'Space beitreten',
      'join.space.popup': 'Manche klicken darauf ausversehen, also willst du wirklich diesem Space beitreten?',
    }
  };
}