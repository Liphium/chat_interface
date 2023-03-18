import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';

class ServerSetup extends Setup {
  ServerSetup() : super('loading.server', true);

  @override
  Future<Widget?> load() async {
    return const ServerSelectorPage();
  }
}

class ServerSelectorPage extends StatelessWidget {
  const ServerSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Select a server:'),
              verticalSpacing(defaultSpacing * 2),
              ElevatedButton(
                onPressed: () => setupManager.next(),
                child: const Text('Local server'),
              ),
              verticalSpacing(defaultSpacing),
              ElevatedButton(
                onPressed: () {
                  basePath = 'http://server.fajurion.com:3000';
                  setupManager.next();
                },
                child: const Text('Fajurion network'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}