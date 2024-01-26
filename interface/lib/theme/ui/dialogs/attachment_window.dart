import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ImagePreviewWindow extends StatelessWidget {
  final File file;

  const ImagePreviewWindow({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final random = Random();
          final randomOffset = random.nextDouble() * 8 + 5;
          final randomHz = random.nextDouble() * 1 + 1;

          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Animate(
                  effects: [
                    ScaleEffect(
                      delay: 100.ms,
                      duration: 500.ms,
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      alignment: Alignment.center,
                      curve: const ElasticOutCurve(0.8),
                    ),
                    ShakeEffect(
                      delay: 100.ms,
                      duration: 400.ms,
                      hz: randomHz,
                      offset: Offset(random.nextBool() ? randomOffset : -randomOffset, random.nextBool() ? randomOffset : -randomOffset),
                      rotation: 0,
                      curve: Curves.decelerate,
                    ),
                    FadeEffect(delay: 100.ms, duration: 250.ms, curve: Curves.easeOut)
                  ],
                  child: SizedBox(
                    height: constraints.maxHeight * 0.6,
                    child: GestureDetector(
                      onTap: () => {},
                      child: Image.file(file),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        )
      ],
    );
  }
}
