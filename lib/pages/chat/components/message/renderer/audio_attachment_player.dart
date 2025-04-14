import 'dart:async';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_zap_renderer.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:signals/signals_flutter.dart';

class AudioAttachmentPlayer extends StatefulWidget {
  final AttachmentContainer container;

  const AudioAttachmentPlayer({super.key, required this.container});

  @override
  State<AudioAttachmentPlayer> createState() => _AudioAttachmentPlayerState();
}

class _AudioAttachmentPlayerState extends State<AudioAttachmentPlayer> with SignalsMixin {
  final _player = AudioPlayer();
  late final _playing = createSignal(false);
  late final _currentMax = createSignal<Duration?>(null);
  late final _currentDuration = createSignal<Duration?>(null);
  bool _paused = false;
  late final _hoverPosition = createSignal<double?>(null);

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    _player.positionStream.listen((duration) {
      _currentDuration.value = duration;
    });
    _player.durationStream.listen((max) {
      _currentMax.value = max;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 350),
      child: Container(
        padding: const EdgeInsets.all(defaultSpacing),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultSpacing),
          color: Get.theme.colorScheme.primaryContainer,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.library_music,
                      size: sectionSpacing * 2,
                      color: Get.theme.colorScheme.onPrimary,
                    ),
                    horizontalSpacing(defaultSpacing),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              widget.container.name,
                              style: Get.theme.textTheme.labelMedium,
                            ),
                          ),
                          Flexible(
                            child: Watch(
                              (ctx) => Text(
                                !widget.container.error.value
                                    ? formatFileSize(1000)
                                    : 'file.not_uploaded'.tr,
                                style: Get.theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    horizontalSpacing(defaultSpacing),
                  ],
                ),

                //* Button
                Watch((ctx) {
                  if (widget.container.downloading.value) {
                    return SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: Get.theme.colorScheme.onPrimary,
                        value: widget.container.percentage.value,
                      ),
                    );
                  }

                  if (widget.container.error.value) {
                    return IconButton(
                      onPressed: () {
                        AttachmentController.downloadAttachment(widget.container, retry: true);
                      },
                      icon: const Icon(Icons.refresh),
                    );
                  }

                  if (!widget.container.downloaded.value) {
                    return IconButton(
                      onPressed: () {
                        AttachmentController.downloadAttachment(widget.container);
                      },
                      icon: const Icon(Icons.download),
                    );
                  }

                  return LoadingIconButton(
                    onTap: () async {
                      if (_playing.value) {
                        await _player.pause();
                        _playing.value = false;
                        _paused = true;
                      } else {
                        if (_paused) {
                          unawaited(_player.play());
                          _paused = false;
                          _playing.value = true;
                          return;
                        }

                        await _player.setFilePath(widget.container.file!.path);
                        await _player.setVolume(0.2);
                        unawaited(_player.play());
                        _playing.value = true;
                      }
                    },
                    icon: _playing.value ? Icons.pause : Icons.play_arrow,
                    background: true,
                    color: Get.theme.colorScheme.onPrimary,
                    backgroundColor: Get.theme.colorScheme.primary,
                  );
                }),
              ],
            ),
            verticalSpacing(defaultSpacing),
            LayoutBuilder(
              builder: (context, constraints) {
                if (_currentDuration.value == null || _currentMax.value == null) {
                  return Container(
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      color: Get.theme.colorScheme.primary,
                    ),
                  );
                }

                // Render the current duration
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onHover: (event) {
                    _hoverPosition.value = event.localPosition.dx;
                  },
                  onExit: (event) => _hoverPosition.value = null,
                  child: GestureDetector(
                    onTap: () {
                      final percentage = (_hoverPosition.value! / constraints.maxWidth);
                      _player.seek(
                        Duration(
                          milliseconds: (_currentMax.value!.inMilliseconds * percentage).toInt(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            color: Get.theme.colorScheme.primary,
                          ),
                        ),
                        Watch(
                          (ctx) => AnimatedContainer(
                            duration: Duration(milliseconds: 100),
                            height: 10,
                            width:
                                constraints.maxWidth *
                                (_hoverPosition.value == null
                                        ? (_currentDuration.value!.inMilliseconds /
                                            _currentMax.value!.inMilliseconds)
                                        : (_hoverPosition.value! / constraints.maxWidth))
                                    .clamp(0, 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(defaultSpacing),
                              color: Get.theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
