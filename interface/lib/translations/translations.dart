import 'package:chat_interface/translations/chat.dart';
import 'package:chat_interface/translations/errors.dart';
import 'package:chat_interface/translations/general.dart';
import 'package:chat_interface/translations/settings.dart';
import 'package:chat_interface/translations/setup.dart';
import 'package:chat_interface/translations/spaces.dart';
import 'package:get/get.dart';

class MainTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys {

    final translations = [
      GeneralTranslations(), SetupTranslations(), ErrorTranslations(), ChatPageTranslations(), SettingsTranslations(),
      SpacesTranslations()
    ];
    final newTranslations = <String, Map<String, String>>{};
    
    // Merge the maps
    for (var translation in translations) {
      final translationsToAdd = translation.keys;
      for (var key in translationsToAdd.keys) {
        if (newTranslations.containsKey(key)) {
          newTranslations[key]!.addAll(translationsToAdd[key]!);
        } else {
          newTranslations[key] = translationsToAdd[key]!;
        }
      }
    }
    return newTranslations;
  }
}