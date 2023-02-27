
import 'dart:convert';

/// An event is sent from the server to the client when a [Message] was parsed by the server.
class Event {

  /// Name of the event
  final String name;

  /// Data of the event
  final Map<String, dynamic> data;

  /// ID of the sender
  final int sender;

  Event(this.sender, this.name, this.data);
  Event.fromMap(Map<String, dynamic> map) : this(map['sender'], map['name'], map['data']);
  Event.fromJson(String json) : this.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() => {
    'sender': sender,
    'name': name,
    'data': data,
  };

  String toJson() => jsonEncode(toMap());
}

/// A message is sent to the server to perform an action.
class Message {

  /// Action to perform
  final String action;

  /// Data of the action
  final Map<String, dynamic> data;

  Message(this.action, this.data);
  Message.fromMap(Map<String, dynamic> map) : this(map['action'], map['data']);
  Message.fromJson(String json) : this.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() => {
    'action': action,
    'data': data,
  };

  String toJson() => jsonEncode(toMap());
}