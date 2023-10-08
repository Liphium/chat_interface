import 'package:chat_interface/pages/status/starting_page.dart';
import 'package:chat_interface/theme/theme_manager.dart';
import 'package:chat_interface/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return GetX<ThemeManager>(
      builder: (manager) {
        return GetMaterialApp(
          title: 'fj.chat',
          theme: manager.themes[manager.currentTheme.value].getData(manager.brightness.value),
          translations: MainTranslations(),
          locale: Get.deviceLocale,
          fallbackLocale: const Locale("en", "US"),
          home: const StartingPage(),
          debugShowCheckedModeBanner: false,
        );
      }
    );
  }
}