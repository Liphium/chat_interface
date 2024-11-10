import 'dart:math';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liphium_bridge/liphium_bridge.dart';

class ImagePreviewWindow extends StatelessWidget {
  final ui.Image? image;
  final String? url;
  final XFile? file;

  const ImagePreviewWindow({super.key, this.image, this.file, this.url});

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
                      child: image != null
                          ? RawImage(image: image)
                          : url == null
                              ? XImage(file: file!)
                              : Image.network(url!),
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
