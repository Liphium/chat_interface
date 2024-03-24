// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.28.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// The type `OutputDevice` is not used by any `pub` functions, thus it is ignored.

Stream<LogEntry> createLogStream({dynamic hint}) =>
    RustLib.instance.api.createLogStream(hint: hint);

Stream<Action> createActionStream({dynamic hint}) =>
    RustLib.instance.api.createActionStream(hint: hint);

Future<void> startTalkingEngine({dynamic hint}) =>
    RustLib.instance.api.startTalkingEngine(hint: hint);

Future<void> testVoice(
        {required String device, required int detectionMode, dynamic hint}) =>
    RustLib.instance.api
        .testVoice(device: device, detectionMode: detectionMode, hint: hint);

Future<void> stop({dynamic hint}) => RustLib.instance.api.stop(hint: hint);

Future<void> setMuted({required bool muted, dynamic hint}) =>
    RustLib.instance.api.setMuted(muted: muted, hint: hint);

Future<void> setDeafen({required bool deafened, dynamic hint}) =>
    RustLib.instance.api.setDeafen(deafened: deafened, hint: hint);

Future<bool> isMuted({dynamic hint}) =>
    RustLib.instance.api.isMuted(hint: hint);

Future<bool> isDeafened({dynamic hint}) =>
    RustLib.instance.api.isDeafened(hint: hint);

Future<void> setAmplitudeLogging(
        {required bool amplitudeLogging, dynamic hint}) =>
    RustLib.instance.api
        .setAmplitudeLogging(amplitudeLogging: amplitudeLogging, hint: hint);

Future<bool> isAmplitudeLogging({dynamic hint}) =>
    RustLib.instance.api.isAmplitudeLogging(hint: hint);

Future<void> setTalkingAmplitude({required double amplitude, dynamic hint}) =>
    RustLib.instance.api.setTalkingAmplitude(amplitude: amplitude, hint: hint);

Future<double> getTalkingAmplitude({dynamic hint}) =>
    RustLib.instance.api.getTalkingAmplitude(hint: hint);

Future<void> setSilentMute({required bool silentMute, dynamic hint}) =>
    RustLib.instance.api.setSilentMute(silentMute: silentMute, hint: hint);

Stream<double> createAmplitudeStream({dynamic hint}) =>
    RustLib.instance.api.createAmplitudeStream(hint: hint);

Future<void> deleteAmplitudeStream({dynamic hint}) =>
    RustLib.instance.api.deleteAmplitudeStream(hint: hint);

Future<List<InputDevice>> listInputDevices({dynamic hint}) =>
    RustLib.instance.api.listInputDevices(hint: hint);

Future<String> getDefaultId({dynamic hint}) =>
    RustLib.instance.api.getDefaultId(hint: hint);

Future<void> setInputDevice({required String id, dynamic hint}) =>
    RustLib.instance.api.setInputDevice(id: id, hint: hint);

Future<void> setOutputDevice({required String id, dynamic hint}) =>
    RustLib.instance.api.setOutputDevice(id: id, hint: hint);

class Action {
  final String action;
  final String data;

  const Action({
    required this.action,
    required this.data,
  });

  @override
  int get hashCode => action.hashCode ^ data.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Action &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          data == other.data;
}

class InputDevice {
  final String id;
  final String displayName;
  final int sampleRate;
  final bool bestQuality;

  const InputDevice({
    required this.id,
    required this.displayName,
    required this.sampleRate,
    required this.bestQuality,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      displayName.hashCode ^
      sampleRate.hashCode ^
      bestQuality.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputDevice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          sampleRate == other.sampleRate &&
          bestQuality == other.bestQuality;
}

class LogEntry {
  final int timeSecs;
  final String tag;
  final String msg;

  const LogEntry({
    required this.timeSecs,
    required this.tag,
    required this.msg,
  });

  @override
  int get hashCode => timeSecs.hashCode ^ tag.hashCode ^ msg.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntry &&
          runtimeType == other.runtimeType &&
          timeSecs == other.timeSecs &&
          tag == other.tag &&
          msg == other.msg;
}
