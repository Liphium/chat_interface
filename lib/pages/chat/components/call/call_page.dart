import 'package:chat_interface/pages/chat/components/call/call_rectangle.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
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

// For no notifications in calls (totally not for the hero transition)
class CallExpandedPage extends StatelessWidget {
  const CallExpandedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 350,
            child: Sidebar(),
          ),
          Expanded(
            child: CallRectangle(),
          ),
        ],
      ),
    );
  }
}