import 'package:chat_interface/pages/chat/components/spaces/call_rectangle.dart';
import 'package:flutter/material.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CallRectangle()
    );
  }
}