import 'dart:math';

import 'package:chat_interface/pages/chat/messages/message_formatters.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum TextFormattingType {
  bold,
  italic,
  lineThrough,
  underline,
  pattern;

  TextStyle apply(TextStyle base, {TextStyle? pattern}) {
    switch (this) {
      case TextFormattingType.bold:
        return base.copyWith(fontWeight: FontWeight.bold);
      case TextFormattingType.italic:
        return base.copyWith(fontStyle: FontStyle.italic);
      case TextFormattingType.underline:
        return base.copyWith(decoration: TextDecoration.combine([base.decoration ?? TextDecoration.none, TextDecoration.underline]));
      case TextFormattingType.lineThrough:
        return base.copyWith(decoration: TextDecoration.combine([base.decoration ?? TextDecoration.none, TextDecoration.lineThrough]));
      case TextFormattingType.pattern:
        return pattern ?? base;
    }
  }
}

abstract class PatternAutomaton {
  int _count = 0;
  int _currentStart = 0;
  bool _incremented = false;
  List<(int, int, List<TextFormattingType>)> _currentState = [];

  void run(int index, String prevChar, String char) {
    // Evaluate the result of the automaton
    var (pattern, valid, invalid, formatting) = evaluate(prevChar, char);
    if (valid) {
      _currentStart = _count;
    }
    if (invalid) {
      final toRemove = _currentState.length - _currentStart;
      _currentState.removeRange(_currentStart, _currentState.length);
      _count -= toRemove;
    }

    // If the pattern is currently being scanned, set the formatting type to pattern
    if (pattern) {
      formatting = [TextFormattingType.pattern];
    }

    if (formatting.isEmpty) {
      // Reset the current state to make sure it will start rendering again from the beginning
      if (!_incremented) {
        _incremented = true;
        _count++;
        _currentStart = _count + 1;
      }
      sendLog("$char | skip $_count");
      return;
    }
    _incremented = false;

    // Apply the current formatting
    if (_currentState.length == _count) {
      sendLog("$char | add new $valid $invalid $_count");
      _currentState.add((index, index + 1, formatting));
    } else {
      final (currStart, currEnd, currFmt) = _currentState[_count];
      sendLog("$char | add existing $valid $invalid $_count");

      // If there is no new formatting, leave it be and add the current thing on top
      if (listEquals(currFmt, formatting)) {
        _currentState[_count] = (currStart, currEnd + 1, currFmt);
      } else {
        // If there is new formatting, start a new range
        _currentState.add((currEnd, currEnd + 1, formatting));
        _count += 1;
      }
    }
  }

  List<(int, int, List<TextFormattingType>)> getResult() {
    return _currentState;
  }

  /// Reset all of the state of the automaton.
  void resetState() {
    _currentState = [];
  }

  /// Evaluate an automaton for one char and the previous one.
  ///
  /// The first element is whether the element was matched by the automaton.
  /// The second element is whether or not the entire pattern that was just matched is invalid.
  /// The third element is whether a snapshot should be saved and the pattern was valid.
  /// The fourth element are the currently active types of formatting.
  (bool, bool, bool, List<TextFormattingType>) evaluate(String prevChar, String char);
}

class TextEvaluator {
  final automatons = [
    BoldItalicAutomaton(),
    StrikethroughAutomaton(),
    UnderlineAutomaton(),
  ];

  List<TextSpan> evaluate(String text, TextStyle startStyle) {
    // Reset the state of the automatons
    for (var automaton in automatons) {
      automaton.resetState();
    }

    // Run all the automatons
    var prevChar = "";
    for (int i = 0; i < text.length; i++) {
      final char = text.characters.elementAt(i);
      for (var automaton in automatons) {
        automaton.run(i, prevChar, char);
      }
      prevChar = char;
    }
    for (var automaton in automatons) {
      automaton.run(text.length, prevChar, "");
    }

    // Collect all ranges from automatons
    List<(int, int, List<TextFormattingType>)> allRanges = [];
    for (var automaton in automatons) {
      allRanges.addAll(automaton.getResult());
    }

    // Sort ranges
    allRanges.sort((a, b) => a.$1.compareTo(b.$1));

    // Build text spans
    List<TextSpan> spans = [];
    int currentIndex = 0;
    int lastEnd = 0;

    while (currentIndex < allRanges.length) {
      var (currentStart, currentEnd, currentFmt) = allRanges[currentIndex];
      List<List<TextFormattingType>> currentFormats = [currentFmt];

      // Parse all the ranges into a non-overlapping list
      List<(int, int, List<List<TextFormattingType>>)> ranges = [];
      if (lastEnd < currentStart) {
        ranges.add((lastEnd, currentStart, []));
      }

      // TODO: This algorithm is not perfect, it won't catch 3 patterns combined for example
      while (allRanges.length > currentIndex + 1) {
        // Check for overlap, if it doesn't go out
        final (nextStart, nextEnd, nextFormats) = allRanges[currentIndex + 1];
        if (nextStart < currentEnd) {
          // Make sure to apply current formats in case the next starts after the current start
          if (currentStart != nextStart) {
            ranges.add((currentStart, nextStart, currentFormats));
          }

          if (currentEnd < nextEnd) {
            // If the current range ends before the next one, make sure to separate the ranges properly
            currentFormats.add(nextFormats);
            ranges.add((nextStart, currentEnd, currentFormats));
            currentStart = currentEnd;
            currentEnd = nextEnd;
            currentFormats.removeAt(0);
          } else if (currentEnd > nextEnd) {
            // If the current range ends after the next one, make sure to apply the formatting only in the next range
            currentFormats.add(nextFormats);
            ranges.add((nextStart, nextEnd, currentFormats));
            currentFormats.removeLast();
          }
          currentIndex++;
        } else {
          break;
        }
      }
      ranges.add((currentStart, currentEnd, currentFormats));

      // Translate to the actual text spans
      for (var (start, end, formats) in ranges) {
        // Compute style
        TextStyle base = startStyle;
        for (var format in formats) {
          for (var f in format) {
            base = f.apply(base);
          }
        }

        sendLog("adding $start-$end: $formats");
        // The min is there because the pattern evaluator has to evaluate the last character as nothing to
        // tell the automaton to finish its final range (this extends the range 1 beyond the original text)
        spans.add(TextSpan(text: text.substring(start, min(text.length, end)), style: base));
      }

      currentIndex++;
      lastEnd = currentEnd;
    }

    return spans;
  }
}
