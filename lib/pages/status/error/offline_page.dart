import 'dart:io';

import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/material.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('You are offline'),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => setupManager.restart(),
                child: const Text('Retry'),
              ),
              ElevatedButton(
                onPressed: () => exit(0),
                child: const Text('Exit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}