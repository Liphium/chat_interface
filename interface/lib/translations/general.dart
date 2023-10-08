import 'package:get/get.dart';

class GeneralTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {

    //* English US
    'en_US': {
      // Actions
      'create': 'Create',
      'ok': 'Okay',
      'retry': 'Retry',
      'back': 'Back',

      // Time TODO: Differentiate between PM and AM
      'time.now': 'Today at @hour:@minute',
      'time': '@month/@day/@year @hour:@minute',
    },

    //* German
    'de_DE': {
      // Actions
      'create': 'Erstellen',
      'ok': 'Verstanden',
      'retry': 'Nochmal versuchen',
      'back': 'Zurück',

      // Time
      'time.now': 'Heute um @hour:@minute',
      'time': '@day.@month.@year @hour:@minute',
    }
  };
}