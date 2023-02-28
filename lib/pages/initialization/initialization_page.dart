import 'package:chat_interface/connection/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../util/vertical_spacing.dart';

class InitializationPage extends StatefulWidget {
  const InitializationPage({super.key});

  @override
  State<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage> {

  @override
  Widget build(BuildContext context) {
    startConnection("");

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.storage,
              size: 150,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shimmer(color: Colors.deepPurpleAccent.shade100, size: 0.8, delay: 1000.ms, duration: 1500.ms, curve: Curves.bounceOut),
            verticalSpacing(defaultSpacing * 0.1),
            Text('node.message'.tr)
          ],
        ),
      )
    );
  }
}