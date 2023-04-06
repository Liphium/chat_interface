import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class CallControls extends StatefulWidget {
  const CallControls({super.key});

  @override
  State<CallControls> createState() => _CallControlsState();
}

class _CallControlsState extends State<CallControls> {

  final _audioInputs = <MediaDevice>[].obs;
  final _audioOutputs = <MediaDevice>[].obs;
  final _videoInputs = <MediaDevice>[].obs;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}