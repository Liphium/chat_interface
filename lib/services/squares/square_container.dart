import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/util/logging_framework.dart';

class SquareContainer extends ConversationContainer {
  late List<Topic> topics;

  SquareContainer(super.name, this.topics);

  @override
  SquareContainer.fromJson(Map<String, dynamic> json) : super(json["name"]) {
    topics = [];
    sendLog(json["topics"]);
    if (json["topics"] == null || json["topics"].isEmpty) {
      return;
    }
    topics.addAll(json["topics"].map((t) => Topic.fromJson(t)).toList());
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json["topics"] = topics.map((t) => t.toJson()).toList();
    return json;
  }
}

class Topic {
  final String id;
  final String name;

  Topic(this.id, this.name);
  Topic.fromJson(Map<String, dynamic> json) : this(json["id"], json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
