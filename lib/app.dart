import 'package:chat_interface/pages/status/setup/setup_page.dart';
import 'package:chat_interface/theme/theme_manager.dart';
import 'package:chat_interface/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        title: 'Liphium',
        theme: Get.find<ThemeManager>().currentTheme.value,
        translations: MainTranslations(),
        locale: Get.deviceLocale,
        fallbackLocale: const Locale("en", "US"),
        home: const SetupPage(),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
