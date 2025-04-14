import 'package:chat_interface/pages/chat/components/townsquare/townsquare_bar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class TownsquarePage extends StatefulWidget {
  const TownsquarePage({super.key});

  @override
  State<TownsquarePage> createState() => _TownsquarePageState();
}

class _TownsquarePageState extends State<TownsquarePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const TownsquareBar(),
          horizontalSpacing(defaultSpacing),
          const SizedBox(width: 700, child: Placeholder()),
        ],
      ),
    );
  }
}
