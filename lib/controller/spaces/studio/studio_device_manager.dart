import 'dart:async';

import 'package:chat_interface/pages/settings/app/audio_settings.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/src/rust/api/audio_devices.dart' as libdevices;
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:signals/signals_flutter.dart';

class StudioDeviceManager {
  // State for the microphone selector
  static final microphones = listSignal<SelectableItem>([]);
  static final selectedMicrophone = computed(() {
    // Try to find the currently selected device
    final selected = AudioSettings.microphone.getValue();
    int i = 0;
    for (var mic in microphones.value) {
      // If it's currently selected, return the index
      if (mic.label == selected) {
        return i;
      }
      i++;
    }

    // Return index 0 (default microphone)
    return 0;
  });

  // State for the output device selector
  static final outputDevices = listSignal<SelectableItem>([]);
  static final selectedOutputDevice = computed(() {
    // Try to find the currently selected output device
    final selected = AudioSettings.outputDevice.getValue();
    int i = 0;
    for (var device in outputDevices.value) {
      // If it's currently selected, return the index
      if (device.label == selected) {
        return i;
      }
      i++;
    }

    // Return index 0 (default output device)
    return 0;
  });

  static Timer? _timer;
  static void init() {
    _timer?.cancel();
    _timer = Timer.periodic(10.seconds, (timer) {
      _updateMicrophones();
      _updateOutputDevices();
    });
  }

  /// Convert all the output devices from libspaceship to selectable items for the selector
  static Future<void> _updateOutputDevices() async {
    // Add the default output device as a first option
    final defaultDevice = await libdevices.getDefaultOutputDevice();
    if (outputDevices.disposed) {
      return;
    }
    final newList = <SelectableItem>[
      SelectableItem("Default (${defaultDevice.name})", Icons.speaker),
    ];

    // Add all the other devices
    for (var device in await libdevices.getOutputDevices()) {
      newList.add(SelectableItem(device.name, Icons.speaker));
    }

    // Only update in case necessary
    if (outputDevices.value != newList) {
      outputDevices.value = newList;
    }
  }

  /// Convert all the microphones from libspaceship to selectable items for the selector
  static Future<void> _updateMicrophones() async {
    // Add the default microphone as a first option
    final defaultMicrophone = await libdevices.getDefaultInputDevice();
    if (microphones.disposed) {
      return;
    }
    final newList = <SelectableItem>[
      SelectableItem("Default (${defaultMicrophone.name})", Icons.mic),
    ];

    // Add all the other microphones
    for (var mic in await libdevices.getInputDevices()) {
      newList.add(SelectableItem(mic.name, Icons.mic));
    }

    // Only update in case necessary
    if (microphones.value != newList) {
      microphones.value = newList;
    }
  }
}
