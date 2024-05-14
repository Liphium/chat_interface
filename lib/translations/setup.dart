import 'package:get/get.dart';

class SetupTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
          // Error page
          'retry.text.1': 'Trying again in',
          'retry.text.2': 'seconds.',

          // General setup
          'setup.choose.instance': 'Choose an instance.',
          'setup.instance.name': 'Enter a new name',
          'setup.choose.server': 'Choose a server',
          'server.choose.server.connecting': 'Currently connecting to',
          'setup.policy': 'Your privacy on Liphium.',
          'setup.policy.text':
              'By pressing \'Accept\', you acknowledge that you have carefully reviewed and accepted our Privacy Policy and Terms of Service which you can read by clicking on \'View agreements\' below, after which the \'Accept\' button will appear.',
          'setup.policy.error': 'It seems like we couldn\'t open a browser on your device. Please check your internet connection or contact the developers of this app.',

          // Login/register
          'register.title': 'Register an account.',
          'placeholder.username': 'test123',
          'placeholder.display_name': 'Test 123',
          'placeholder.password': 'yourmum123 (don\'t use this)',
          'placeholder.invite': 'your-invite-code',
          'password.invalid': 'Please enter a password that is longer than 8 characters.',
          'invite.invalid': 'Please enter a valid invite code.',
          'invite.info': 'Invite codes are your way to get into the app. You can get one from a friend or from official sources.',
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
          'login.register_reminder': 'Don\'t have an account? There is a register button below the next button.',
          'login.no_account': 'Register one',
          'input.password': 'Your password, please',
          'login.forgot.text': 'Forgot your password?',
          'login.forgot': 'Reset it',
        },
      };
}
