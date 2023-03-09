import 'package:chat_interface/pages/chat/chat_page.dart';
import 'package:chat_interface/pages/status/starting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  // This widget is the root of your application.
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