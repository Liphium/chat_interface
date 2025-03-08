import 'package:chat_interface/pages/chat/messages/message_automaton.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  group("message formatter", () {
    test("normal text", () {
      TextEvaluator eval = TextEvaluator();
      final spans = eval.evaluate("hello world", TextStyle(fontSize: 14));

      // The text should be unchanged
      expect(spans[0].text, equals("hello world"));
      expect(spans[0].style!, equals(TextStyle(fontSize: 14.0)));
    });
  });
}
