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
      'placeholder.username': 'Username',
      'placeholder.password': 'Password',
      'placeholder.tag': 'Tag',
      'placeholder.email': 'Email',
      'register.register': 'Register',
      'register.account.text': 'Already have an account?',
      'register.login': 'Login',
      'input.email': 'Your email, please',
      'login.next': 'Next step',
      'login.no_account.text': 'Don\'t have an account?',
      'login.no_account': 'Register one',
      'input.password': 'Your password, please',
      'login.forgot.text': 'Forgot your password?',
      'login.forgot': 'Reset it',
    },

    //* German
    'de_DE': {
      // Error page
      'retry.text.1': 'Versuche es in',
      'retry.text.2': 'Sekunden erneut.',

      // Instance setup
      'setup.choose.instance': 'Wähle eine Instanz.',
      'setup.instance.name': 'Gib einen Namen ein',

      // Login/register
      'register.title': 'Registriere einen Account.',
      'placeholder.username': 'Benutzername',
      'placeholder.password': 'Passwort',
      'placeholder.tag': 'Tag',
      'placeholder.email': 'Email',
      'register.register': 'Registrieren',
      'register.account.text': 'Du hast einen Account?',
      'register.login': 'Einloggen',
      'input.email': 'Deine Email, bitte',
      'login.next': 'Nächster Schritt',
      'login.no_account.text': 'Hast du keinen Account?',
      'login.no_account': 'Registrieren',
      'input.password': 'Dein Passwort, bitte',
      'login.forgot.text': 'Passwort vergessen?',
      'login.forgot': 'Zurücksetzen',
    }
  };
}