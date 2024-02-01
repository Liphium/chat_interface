import 'package:get/get.dart';

class SetupTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
          // Error page
          'retry.text.1': 'Trying again in',
          'retry.text.2': 'seconds.',

          // Instance setup
          'setup.choose.instance': 'Choose an instance.',
          'setup.instance.name': 'Enter a new name',

          // Login/register
          'register.title': 'Register an account.',
          'placeholder.username': 'name',
          'placeholder.password': 'yourmum123 (don\'t use this)',
          'placeholder.tag': '1234',
          'placeholder.invite': 'your-invite-code',
          'password.invalid':
              'Please enter a password that is longer than 8 characters.',
          'invite.invalid': 'Please enter a valid invite code.',
          'invite.info':
              'Invite codes are your way to get into the app. You can get one from a friend or from official sources.',
          'placeholder.email': 'your@email.com',
          'register.verify': 'Verify your email.',
          'register.final': 'Finish your account.',
          'register.email_validation':
              'We sent an email to @email. Please check your inbox and put the code we sent you into the input box below. Oh, and don\'t forget to check the spam folder!',
          'placeholder.code': 'abcdef',
          'email.invalid': 'Please enter a valid email.',
          'register.register': 'Register',
          'register.account.text': 'Already have an account?',
          'register.login': 'Login',
          'input.email': 'Your email, please',
          'login.next': 'Next step',
          'login.no_account.text': 'Don\'t have an account?',
          'login.register_reminder':
              'Don\'t have an account? There is a register button below the next button.',
          'login.no_account': 'Register one',
          'input.password': 'Your password, please',
          'login.forgot.text': 'Forgot your password?',
          'login.forgot': 'Reset it',
        },

        //* German
        'de_DE': {
          /*
          // Error page
          'retry.text.1': 'Versuche es in',
          'retry.text.2': 'Sekunden erneut.',

          // Instance setup
          'setup.choose.instance': 'Wähle eine Instanz.',
          'setup.instance.name': 'Gib einen Namen ein',

          // Login/register
          'register.title': 'Registriere einen Account.',
          'placeholder.username': 'Benutzername',
          'placeholder.password': 'deinemutter123 (bitte nicht benutzen)',
          'placeholder.tag': '1234',
          'placeholder.email': 'deine@email.com',
          'placeholder.invite': 'dein-einladungs-code',
          'password.invalid': 'Bitte gib ein Passwort ein, das länger als 8 Zeichen ist.',
          'invite.invalid': 'Bitte gib eine gültige Einladung ein.',
          'invite.info': 'Einladungen sind dein Weg in die App. Du kannst einen von einem Freund oder von offiziellen Quellen bekommen.',
          'email.invalid': 'Bitte gib eine gültige Email ein.',
          'register.register': 'Registrieren',
          'register.account.text': 'Du hast einen Account?',
          'register.login': 'Einloggen',
          'input.email': 'Deine Email, bitte',
          'login.next': 'Nächster Schritt',
          'login.no_account.text': 'Du hast keinen Account?',
          'login.register_reminder': 'Du hast keinen Accountt? Es gibt einen Link zum Registrieren direkt unter dem "Nächster Schritt"-Knopf.',
          'login.no_account': 'Registrieren',
          'input.password': 'Dein Passwort, bitte',
          'login.forgot.text': 'Passwort vergessen?',
          'login.forgot': 'Zurücksetzen',
          */
        }
      };
}
