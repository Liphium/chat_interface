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

class _AudioAttachmentPlayerState extends State<AudioAttachmentPlayer> {
  final player = AudioPlayer();
  final playing = false.obs;
  final currentMax = Rx<Duration?>(null);
  final currentDuration = Rx<Duration?>(null);
  bool paused = false;
  final hoverPosition = Rx<double?>(null);

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    player.positionStream.listen(
      (duration) {
        currentDuration.value = duration;
      },
    );
    player.durationStream.listen(
      (max) {
        currentMax.value = max;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 350,
      ),
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
                            child: Obx(
                              () => Text(
                                !widget.container.error.value ? formatFileSize(1000) : 'file.not_uploaded'.tr,
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
                Obx(() {
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
                        Get.find<AttachmentController>().downloadAttachment(widget.container, retry: true);
                      },
                      icon: const Icon(Icons.refresh),
                    );
                  }

                  if (!widget.container.downloaded.value) {
                    return IconButton(
                      onPressed: () {
                        Get.find<AttachmentController>().downloadAttachment(widget.container);
                      },
                      icon: const Icon(Icons.download),
                    );
                  }

                  return LoadingIconButton(
                    loading: signal(false),
                    onTap: () async {
                      if (playing.value) {
                        await player.pause();
                        playing.value = false;
                        paused = true;
                      } else {
                        if (paused) {
                          unawaited(player.play());
                          paused = false;
                          playing.value = true;
                          return;
                        }

                        await player.setFilePath(widget.container.file!.path);
                        await player.setVolume(0.2);
                        unawaited(player.play());
                        playing.value = true;
                      }
                    },
                    icon: playing.value ? Icons.pause : Icons.play_arrow,
                    background: true,
                    color: Get.theme.colorScheme.onPrimary,
                    backgroundColor: Get.theme.colorScheme.primary,
                  );
                }),
              ],
            ),
            verticalSpacing(defaultSpacing),
            LayoutBuilder(builder: (context, constraints) {
              return Obx(() {
                if (currentDuration.value == null || currentMax.value == null) {
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
                    hoverPosition.value = event.localPosition.dx;
                  },
                  onExit: (event) => hoverPosition.value = null,
                  child: GestureDetector(
                    onTap: () {
                      final percentage = (hoverPosition.value! / constraints.maxWidth);
                      player.seek(Duration(milliseconds: (currentMax.value!.inMilliseconds * percentage).toInt()));
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
                        Obx(
                          () => AnimatedContainer(
                            duration: Duration(milliseconds: 100),
                            height: 10,
                            width: constraints.maxWidth *
                                (hoverPosition.value == null
                                        ? (currentDuration.value!.inMilliseconds / currentMax.value!.inMilliseconds)
                                        : (hoverPosition.value! / constraints.maxWidth))
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
              });
            })
          ],
        ),
      ),
    );
  }
}
