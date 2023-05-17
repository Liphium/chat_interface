import 'package:chat_interface/pages/status/starting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return GetMaterialApp(
      title: 'fj.chat',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: const StartingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}