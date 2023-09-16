import 'package:chat_interface/controller/conversation/livekit/call_controller.dart';
import 'package:chat_interface/controller/conversation/livekit/output_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class VideoEntity extends StatefulWidget {

  final Video video;

  const VideoEntity({super.key, required this.video});

  @override
  State<VideoEntity> createState() => _VideoEntityState();
}

class _VideoEntityState extends State<VideoEntity> {

  final hover = false.obs;

  @override
  Widget build(BuildContext context) {

    CallController controller = Get.find();

    return ClipRRect(
      borderRadius: BorderRadius.circular(defaultSpacing),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: MouseRegion(
      
          onEnter: (_) => hover.value = true,
          onExit: (_) => hover.value = false,
      
          child: Material(
            color: Colors.black,
            child: InkWell(
              onTap: () => Get.find<CallController>().cinemaMode(widget),
              child: Stack(
                children: [
                  
                  //* Video
                  Obx(() => 
                    widget.video.loading.value ?
                    controller.cinemaWidget.value == widget ?
                    Material(
                      color: Colors.black,
                      child: InkWell(
                        onTap: () => Get.find<CallController>().cinemaMode(widget),
                        child: const Center(
                          child: Icon(Icons.fullscreen_exit, color: Colors.white, size: 50),
                        ),
                      ),
                    ) :
                    const Center(child: CircularProgressIndicator()) :
                    VideoTrackRenderer(
                      widget.video.publication.track!,
                      fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    )
                  ),
                  
                  //* Hover
                  Padding(
                    padding: const EdgeInsets.all(defaultSpacing * 0.5),
                    child: Obx(() => 
                      hover.value ?
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.all(defaultSpacing * 0.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(defaultSpacing * 0.25),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.monitor),
                                horizontalSpacing(defaultSpacing * 0.5),
                                Text(
                                  widget.video.member.friend.name,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ) :
                      const SizedBox()
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}