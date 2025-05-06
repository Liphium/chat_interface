import 'dart:convert';
import 'dart:ui';

import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

/// An event is sent from the server to the client when a [ServerAction] was parsed by the server.
class Event {
  /// Name of the event
  final String name;

  /// Data of the event
  final Map<String, dynamic> data;

  Event(this.name, this.data);
  Event.fromMap(Map<String, dynamic> map) : this(map['name'], map['data']);
  Event.fromJson(String json) : this.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() => {'name': name, 'data': data};

  String toJson() => jsonEncode(toMap());
}

/// A message is sent to the server to perform an action.
class ServerAction {
  /// Action to perform
  String action;

  /// Data of the action
  final dynamic data;

  ServerAction(this.action, this.data);
  ServerAction.fromMap(Map<String, dynamic> map) : this(map['action'], map['data']);
  ServerAction.fromJson(String json) : this.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() => {
    'action': action,
    'lc': localeString(Get.locale ?? Get.fallbackLocale ?? const Locale("en", "US")),
    'data': data,
  };

  String toJson() => jsonEncode(toMap());
}
