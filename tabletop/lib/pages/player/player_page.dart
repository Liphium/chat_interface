import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tabletop/layouts/templates/playable_canvas.dart';
import 'package:tabletop/pages/player/table_renderer.dart';
import 'package:tabletop/theme/vertical_spacing.dart';

class PlayerPage extends StatelessWidget {

  final PlayableCanvas canvas;

  const PlayerPage({super.key, required this.canvas});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Get.theme.colorScheme.onBackground,
          padding: const EdgeInsets.all(defaultSpacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Icon(Icons.play_arrow, color: Get.theme.colorScheme.onPrimary, size: 30),
              horizontalSpacing(elementSpacing),
              Text(canvas.name, style: Get.theme.textTheme.titleMedium),
            ],
          ),
        ),
        Expanded(
          child: ClipRect(
            child: TableRenderer(canvas: canvas)
          )
        )
      ],
    );
  }
}