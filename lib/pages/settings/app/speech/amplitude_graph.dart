import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:record/record.dart';


class AmplitudeGraph extends StatefulWidget {

  final MediaDevice device;

  const AmplitudeGraph({Key? key, required this.device}) : super(key: key);

  @override
  State<AmplitudeGraph> createState() => _AmplitudeGraphState();
}

class _AmplitudeGraphState extends State<AmplitudeGraph> {

  // Record object to access microphone
  final Record _record = Record();

  // Stream subscription for amplitude updates
  StreamSubscription? _subscription;

  // Flag to indicate recording status
  bool _isRecording = false;

  @override
  void dispose() {

    // Cancel the subscription and dispose the record object
    _subscription?.cancel();
    _record.dispose();

    super.dispose();
  }

  // Method to start recording and listening to amplitude updates
  void _startRecording() async {

    // Check and request permission if needed
    bool hasPermission = await _record.hasPermission();
    if (hasPermission) {

      final devices = await _record.listInputDevices();

      // Start recording and get the stream of amplitude values
      await _record.start(
        path: "C:/Users/thisi/OneDrive/Dokumente/We(e)b Stuff/FJ/audio/audio.mov", // Leave empty to record to memory
        encoder: AudioEncoder.aacLc,
        device: devices[3]
      );

      Stream<Amplitude> stream = _record.onAmplitudeChanged(300.ms);

      // Set the flag and clear the previous values
      setState(() {
        _isRecording = true;
      });

      // Listen to the stream and update the values list
      _subscription = stream.listen((value) {
        print("Amplitude: ${value.current} | ${value.max}");
      });
    }
  }

  // Method to stop recording and cancel the subscription
  void _stopRecording() async {
    // Stop recording and cancel the subscription
    await _record.stop();
    _subscription?.cancel();
    // Set the flag
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        // Show the device label
        Text(widget.device.label),
        
        // Show a button to start or stop recording based on the flag
        ElevatedButton(
          onPressed: () {
            if (_isRecording) {
              _stopRecording();
            } else {
              _startRecording();
            }
          },
          child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
        ),
      ],
    );
  }
}