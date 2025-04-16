import 'package:chat_interface/services/chat/conversation_service.dart';

class SquareContainer extends ConversationContainer {
  List<Topic> topics;

  SquareContainer(super.name, this.topics);

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

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
