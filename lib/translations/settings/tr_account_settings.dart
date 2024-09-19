import 'package:get/get.dart';

class AccountSettingsTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
          // Data settings
          'settings.data.social': 'Social features',
          'settings.data.social.text':
              'Liphium\'s social features allow you to share things not just with your friends, but also with the people on your instance. You can chat with everyone, but therefore it\'s not encrypted, so we allow you to disable it.',
          'data.social': 'Enable social features',
          'settings.data.profile_picture': 'Profile picture',
          'settings.data.profile_picture.select':
              'Now just zoom and move your image into the perfect spot! So it makes your beauty shine, if you even have any...',
          'settings.data.profile_picture.requirements': 'Can only be a JPEG or PNG and can\'t be larger than 10 MB.',
          'settings.data.profile_picture.remove': 'Remove profile picture',
          'settings.data.profile_picture.remove.confirm': 'Are you sure you want to remove your profile picture?',
          'settings.data.key_requests': 'Synchronization requests',
          'settings.data.key_requests.description': 'If we ask you to accept a key request on another device, you can find them here.',
          'settings.data.permissions': 'Permissions',
          'settings.data.permissions.description':
              'If you don\'t know what this is, it\'s fine. This is just data from the server that we can ask you for in case of problems. Here\'s which permissions you have:',
          'settings.data.account': 'Account data',
          'settings.data.email.description': 'Showing your email would be work. And I don\'t like that, you know.',
          'settings.data.log_out': 'Log out of your account',
          'settings.data.log_out.description':
              'If you log out of your account, we\'ll delete all your data from this device. This includes the keys we use to encrypt stuff on our servers. If you don\'t have these on another device, you will NEVER be able to recover your friends.',
          'settings.data.danger_zone': 'Danger zone',
          'settings.data.danger_zone.description':
              'Hello, and welcome down here! Hope you haven\'t come here to delete your account. If you have, you can do that here. But please don\'t. We\'ll miss you. :(',
          'settings.data.danger_zone.delete_account': 'Delete account',
          'settings.data.danger_zone.delete_account.confirm':
              'This is just a request and your actual data will be deleted in 30 days. We do this to make sure you didn\'t just accidentally click this button and that you are the actual owner of this account. Are you sure you want to delete your account?',
          'settings.data.change_name.dialog': 'Want to change your username? Just provide it below and we\'ll handle it for you.',
          'settings.data.change_display_name.dialog': 'Want to change your display name? We\'ll handle your request right here.',

          // Key sync requests
          'key_requests.empty': 'There are currently no requests to exchange keys with another device.',
          'key_requests.code.title': 'Enter verification code',
          'key_requests.code.description':
              'Please enter the verification code that\'s displayed on the other device. We\'ll use it to verify that the request hasn\'t been modified by the server.',
          'key_requests.code.placeholder': 'abcdef',
          'key_requests.code.error': 'This code is invalid. Please try again.',
          'key_requests.code.button': 'Verify code',

          // Authentication settings
          'settings.authentication.first_factor': 'First factor',
          'settings.authentication.password.description': 'We\'ll not show your password here. That would be stupid.',
          'settings.authentication.change_password.dialog':
              'Let\'s make sure your account is secure again. All your devices (also this one) will be logged out after you click "Save".',
          'settings.authentication.second_factor': 'Second factor',

          // Invite settings (this is mostly alpha only)
          'settings.invites.description':
              "Invites are a token required for creating an account on the chat app. If you want one of your friends to be on here, send them an invite! They are distributed randomly in waves to prevent an influx of too many new users at once and also guarantee that the new users getting in are actually your friends.",
          'settings.invites.generate': 'Generate invite',
          'settings.invites.generated': 'Invite generated! It was copied to your clipboard.',
          'settings.invites.history': 'History',
          'settings.invites.history.description': 'Here are all the invites you already generated. Hover over them to see the token.',
          'settings.invites.history.empty': 'You haven\'t generated any invites yet or they have all been redeemed.',
        },
      };
}
