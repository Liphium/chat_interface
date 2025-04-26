import 'package:get/get.dart';

class SquareTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    //* English US
    'en_US': {
      // Square management
      'squares.create': 'Create Square',
      'squares.name.placeholder': 'Square name',
      'squares.topics.create': 'Create topic',
      'squares.topics.name.placeholder': 'Some chat',
      'squares.topics.too_many':
          'We currently only allow a maximum of 5 topics to be created. Please delete old ones to make space for new ones.',
      'squares.spaces.create': 'Create new Space',
      'squares.spaces.add': 'Add current Space',
      'squares.spaces.name.placeholder': 'Hangout #1',
    },
  };
}
