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
  }

  List<ProcessedText> process(String text, TextStyle style) {
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
    patternMap = Map.fromEntries(patternMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    print(patternMap);

    // Process text
    int lastIndex = 0;
    int mapIndex = 0;
    Map<TextPattern, bool> patternState = {};

    while(lastIndex != text.length) {

      // Grab current index
      int index;
      if(mapIndex >= patternMap.length) {
        index = text.length;
      } else {
        index = patternMap.keys.elementAt(mapIndex);
      }

      // Build style
      TextStyle currentStyle = style;
      for (TextPattern pattern in patternState.keys) {
        if (patternState[pattern]!) {
          currentStyle = pattern.process(currentStyle);
        }
      }

      // Check if span is nessecary
      if(lastIndex != index) {
        spans.add(ProcessedText(text.substring((lastIndex != 0 || patternMap[0] != null ? lastIndex+1 : lastIndex), index), currentStyle));
      }

      // Check for patterns
      if(patternMap.containsKey(index)) {
        for (TextPattern pattern in patternMap[index]!) {
          if (patternState.containsKey(pattern)) {
            patternState[pattern] = !patternState[pattern]!;
          } else {
            patternState[pattern] = true;
          }
        }
      }

      lastIndex = index;
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
    List<int> indices = [];

    int length = 0;
    while (length < text.length) {

      int index = text.indexOf(pattern, length);
      if (index == -1) {
        break;
      }

      indices.add(index);
      length = index + 1;
    }

    return indices;
  }

  TextStyle process(TextStyle style);

}