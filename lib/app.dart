import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/login/login_choose_page.dart';
import 'package:chat_interface/theme/theme_manager.dart';
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
          home: const LoginChoosePage([AuthType.passkey, AuthType.totp]),
          debugShowCheckedModeBanner: false,
        );
      }
    );
  }
}