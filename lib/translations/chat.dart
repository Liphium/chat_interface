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
          'friends.invite_to_space': 'Invite to current space',
          'friends.requests_sent': 'Requests sent',
          'friends.requests': 'Requests',
          'request.sent': 'Request successfully sent!',
          'friends.empty': 'Seems like you don\'t have any friends with that name.',
          'friends.send_request': 'Now just press \'Enter\' whenever you\'re done typing. And we\'ll find your friend for you.',
          'friends.example': 'If you want to add someone, please provide their username#tag. Example: Julian#1234',
          'request.confirm.title': 'Confirm request',
          'request.confirm.text':
              'By sending a friend request, the other person will be able to permantently see your profile (profile picture, description, etc.) unless you change your keys. Are you sure you want to give them this information?',
          'request.already.exists': 'Already exists',
          'request.already.exists.text': 'You already sent a request to this person. We know you\'re excited, but please wait for them to accept your request.',

          // Conversations
          'conversations.placeholder': 'Search',
          'conversations.hidden': "Searching for something else? You can use '.' at the beginning of your query to search for hidden conversations.",
          'conversations.create': 'Create conversation',
          'conversations.name': 'Conversation name',
          'chat.message': 'Say something',
          'chat.members': '@count members',
          'chat.start_space': 'Start a private Space',
          'conversations.leave': 'Leave conversation',
          'conversations.leave.text': 'Are you sure you want to leave this conversation? You will not be able to rejoin unless someone invites you back.',
          'chat.not.signed': 'This message could have been sent by someone else or modified by the server.',
          'conversations.add': 'Add a member',
          'conversations.add.create': 'Create new conversation',
          'choose.members': 'Choose more than one member to create a group chat.',

          // Conversation members
          'chat.make_moderator': 'Make moderator',
          'chat.remove_moderator': 'Remove moderator',
          'chat.remove_admin': 'Remove admin',
          'chat.make_admin': 'Make admin',
          'chat.remove_member': 'Remove member',
          'chat.add_member': 'Add member',
          'chat.admin': 'Admin',
          'chat.moderator': 'Moderator',
          'chat.user': 'User',

          // System messages
          'chat.rank_change.0->1': '@name was promoted to Moderator by @sender.',
          'chat.rank_change.1->2': '@name was promoted to Admin by @sender.',
          'chat.rank_change.1->0': '@name has been demoted to a normal member by @sender.',
          'chat.rank_change.2->1': '@name has been demoted to Moderator by @sender.',
          'chat.token_change': '@name has generated a new conversation invite.',
          'chat.member_join': '@name has joined the conversation.',
          'chat.member_leave': '@name has left the conversation.',
          'chat.new_admin': '@name is now an Admin because the original Admin left the conversation.',

          // Message menu
          'message.info': 'Info',
          'message.copy': 'Copy content',
          'message.profile': 'Open profile',
          'message.delete': 'Delete message',
          'message.info.text': 'This message was sent by @account (@token) at @hour:@minute on @month/@day/@year.',
          'message.info.copy_id': 'Copy ID',
          'message.info.copy_signature': 'Copy signature',
          'message.info.copy_sender': 'Copy sender ID',
          'message.info.copy_cert': 'Copy certificate',

          // Conversation info
          'conversation.info.id': 'Conversation ID: @id',
          'conversation.info.read': 'Read at @clock on @date',
          'conversation.info.update': 'Updated at @clock on @date',
          'conversation.info.members': 'Members: @count',
          'conversation.info.copy_id': 'Copy ID',
          'conversation.info.copy_token': 'Copy token',

          // Files
          'file.dialog': '@name is @size MB large. Choose an option to download it:',
          'download.folder': 'Download into folder',
          'download.app': 'Download into app',

          // Spaces
          'join.space': 'Join Space',
          'join.space.popup': 'Some people click this on accident, so do you really want to join this space?',
          'chat.space_invite': 'Space invitation',
          'chat.space.not_found': 'This space does not exist.',
        },

        //* German
        'de_DE': {
          /*
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
          'request.confirm.title': 'Anfrage bestätigen',
          'request.confirm.text':
              'Wenn du eine Freundschaftsanfrage sendest, wird die andere Person dein Profil (Profilbild, Beschreibung, usw.) dauerhaft sehen können, es sei denn, du änderst deine Schlüssel. Bist du sicher, dass du dieser Person diese Informationen geben willst?',

          // Conversations
          'conversations.placeholder': 'Suche',
          'conversations.hidden': "Suchst du nach etwas anderem? Du kannst '.' am Anfang deiner Suche hinzufügen, um nach versteckten Chats zu suchen.",
          'conversations.create': 'Chat erstellen',
          'conversations.name': 'Gruppenname',
          'chat.message': 'Sag etwas',
          'chat.members': '@count Mitglieder',
          'chat.start_space': 'Privates Space starten',
          'conversations.leave': 'Chat verlassen',
          'conversations.leave.text': 'Bist du sicher, dass du diesen Chat verlassen willst? Du kannst nicht wieder beitreten, es sei denn, jemand lädt dich wieder ein.',
          'chat.not.signed': 'Diese Nachricht könnte von jemand anderem gesendet worden sein oder vom Server verändert worden sein.',

          // Message menu
          'message.info': 'Info',
          'message.copy': 'Text kopieren',
          'message.profile': 'Profil öffnen',
          'message.delete': 'Nachricht löschen',
          'message.info.text': 'Diese Nachricht wurde von @sender (@senderid) um @hour:@minute am @day.@month.@year gesendet.',
          'message.info.copy_signature': 'Signatur kopieren',
          'message.info.copy_sender': 'Sender ID kopieren',
          'message.info.copy_cert': 'Zertifikat kopieren',

          // Conversation members
          'chat.make_moderator': 'Zum Moderator machen',
          'chat.remove_moderator': 'Moderator entfernen',
          'chat.remove_admin': 'Admin entfernen',
          'chat.make_admin': 'Zum Admin machen',
          'chat.remove_member': 'Mitglied entfernen',
          'chat.add_member': 'Mitglied hinzufügen',
          'chat.admin': 'Admin',
          'chat.moderator': 'Moderator',
          'chat.user': 'Mitglied',

          // System messages
          'chat.rank_change.0->1': '@name wurde von @sender zum Moderator befördert.',
          'chat.rank_change.1->2': '@name wurde von @sender zum Admin befördert.',
          'chat.rank_change.1->0': '@name wurde von @sender zu einem normalen Mitglied degradiert.',
          'chat.rank_change.2->1': '@name wurde von @sender zu einem Moderator degradiert.',
          'chat.token_change': '@name hat eine neue Einladung zum Chat erstellt.',
          'chat.member_join': '@name ist dem Chat beigetreten.',
          'chat.member_leave': '@name hat den Chat verlassen.',
          'chat.new_admin': '@name ist jetzt Admin, weil der ursprüngliche Admin den Chat verlassen hat.',

          // Spaces
          'join.space': 'Space beitreten',
          'join.space.popup': 'Manche klicken darauf ausversehen, also willst du wirklich diesem Space beitreten?',
          */
        }
      };
}
