import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';

import 'impl/formatting_patterns.dart';

final TextPatternManager textPatternManager = TextPatternManager();

class TextPatternManager {
  late final List<TextPattern> patterns;

  TextPatternManager() {
    patterns = [];

    // Add patterns
    patterns.add(BoldPattern());
    patterns.add(ItalicPattern());
    patterns.add(UnderlinePattern());
    patterns.add(StrokePattern());
    patterns.add(TrollPattern());
  }

  List<ProcessedText> process(String text, TextStyle style,
      {bool renderPatterns = false}) {
    List<ProcessedText> spans = [];

    // Scan text for patterns
    Map<int, List<TextPattern>> patternMap = {};
    for (TextPattern pattern in patterns) {
      List<int> indices = pattern.scan(text);
      for (int index in indices) {
        if (!patternMap.containsKey(index)) {
          patternMap[index] = [];
        }
        patternMap[index]!.add(pattern);
      }
    }

    // Sort patterns
    patternMap = Map.fromEntries(
        patternMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

    // Process text
    int lastIndex = 0;
    int lastLength = 0;
    int mapIndex = 0;
    Map<TextPattern, bool> patternState = {};

    while (lastIndex != text.length) {
      // Grab current index
      int index;
      int lengthAfter = 0;
      if (mapIndex >= patternMap.length) {
        index = text.length;
      } else {
        index = patternMap.keys.elementAt(mapIndex);
        if (mapIndex != patternMap.length - 1) {
          lengthAfter = patternMap[patternMap.keys.elementAt(mapIndex + 1)]!
              .first
              .pattern
              .length;
        }
      }

      // Build style
      TextStyle currentStyle = style;
      int length = 0;
      for (TextPattern pattern in patternState.keys) {
        if (patternState[pattern]!) {
          currentStyle = pattern.process(currentStyle);
          if (pattern.pattern.length > length) {
            length = pattern.pattern.length;
          }
        }
      }

      // Check if span is nessecary
      if (lastIndex != index) {
        if (currentStyle == style && !renderPatterns) {
          spans.add(ProcessedText(
              text.substring(lastIndex + lastLength, index - lengthAfter),
              currentStyle));
        } else {
          spans.add(
              ProcessedText(text.substring(lastIndex, index), currentStyle));
        }
      }

      // Check for patterns
      if (patternMap.containsKey(index)) {
        for (TextPattern pattern in patternMap[index]!) {
          if (patternState.containsKey(pattern)) {
            patternState[pattern] = !patternState[pattern]!;
          } else {
            patternState[pattern] = true;
          }
        }
      }

      lastIndex = index;
      lastLength = length;
      mapIndex++;
    }

    return spans;
  }
}

class ProcessedText {
  final String text;
  final TextStyle style;

  ProcessedText(this.text, this.style);
}

abstract class TextPattern {
  final String pattern;

  TextPattern(this.pattern);

  // scan returns a list of indices where the pattern is found in the text
  List<int> scan(String text) {
    sendLog(pattern);
    List<int> indices = [];

    int length = 0;
    bool enable = false;
    while (length < text.length) {
      int index = text.indexOf(pattern, length);
      if (index == -1) {
        break;
      }

      // Prevent patterns right next to each other
      if (index != length) {
        indices.add(index + (!enable ? pattern.length : 0));
        enable = !enable;
      } else {
        sendLog("Removed double pattern $index $length");
        indices.remove(index + (enable ? pattern.length : 0) - 1);
      }

      length = index + 1;
    }

    return indices;
  }

  TextStyle process(TextStyle style);
}
