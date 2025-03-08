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
  bool logging = false;
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
      _currentState.removeRange(_currentStart, _currentState.length);
      _count = _currentState.length - 1;
    }

    // If the pattern is currently being scanned, set the formatting type to pattern
    if (pattern) {
      formatting = [TextFormattingType.pattern];
    }

    if (formatting.isEmpty) {
      // Reset the current state to make sure it will start rendering again from the beginning
      if (!_incremented && _currentState.isNotEmpty) {
        _incremented = true;
        _count++;
        _currentStart = _count + 1;
      }
      if (logging) {
        sendLog("$char | skip valid=$valid invalid=$invalid count=$_count");
      }
      return;
    }
    _incremented = false;

    // Apply the current formatting
    if (_currentState.length == _count) {
      if (logging) {
        sendLog("$char | add new valid=$valid invalid=$invalid count=$_count");
      }
      _currentState.add((index, index + 1, formatting));
    } else {
      final (currStart, currEnd, currFmt) = _currentState[_count];
      if (logging) {
        sendLog("$char | add existing $valid $invalid $_count");
      }

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
    _count = 0;
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
    List<(int, int, List<List<TextFormattingType>>)> ranges = [];
    for (var automaton in automatons) {
      if (ranges.isEmpty) {
        // If nothing is there yet, add all the ranges from the automaton (shouldn't have overlaps)
        for (var (start, end, formatting) in automaton.getResult()) {
          // Only add if it's a valid range
          if (end >= start) {
            ranges.add((start, end, [formatting]));
          }
        }
      } else {
        // Merge all of the ranges into it
        for (var range in automaton.getResult()) {
          ranges = mergeRanges(range, ranges);
        }
      }
    }

    // Create the text spans from the ranges
    List<TextSpan> spans = [];
    int lastEnd = 0;
    for (var (start, end, formattings) in ranges) {
      // Add everything before the range in case necessary
      if (start != lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, start),
          style: startStyle,
        ));
      }

      // Build the formatting for the range
      TextStyle style = startStyle;
      for (var formatting in formattings) {
        for (var format in formatting) {
          style = format.apply(style);
        }
      }

      // Add the range itself
      spans.add(TextSpan(
        text: text.substring(start, end),
        style: style,
      ));
      lastEnd = end;
    }

    // Add the rest of the text (in case necessary)
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, text.length),
        style: startStyle,
      ));
    }

    return spans;
  }

  /// Merge a range with text formatting ([toAdd]) into a non-overlapping set of base ([ranges]) ranges.
  ///
  /// Returns the merged ranges (also non-overlapping).
  List<(int, int, List<List<TextFormattingType>>)> mergeRanges(
    (int, int, List<TextFormattingType>) toAdd,
    List<(int, int, List<List<TextFormattingType>>)> ranges,
  ) {
    List<(int, int, List<List<TextFormattingType>>)> merged = [];

    var (start, end, formatting) = toAdd;
    for (var (mStart, mEnd, mFormatting) in ranges) {
      // Add the rest if current range is already past it
      if (start < end && mStart > end) {
        merged.add((start, end, [formatting]));
      }

      // Check if they are overlapping
      if (mEnd < start || mStart > end || start >= end) {
        merged.add((mStart, mEnd, mFormatting));
        continue;
      }

      if (start <= mStart) {
        if (end <= mEnd) {
          merged.add((mStart, end, [...mFormatting, formatting]));
          merged.add((end, mEnd, mFormatting));
        } else if (end > mEnd) {
          if (start != mStart) {
            merged.add((start, mStart, [formatting]));
          }
          merged.add((mStart, mEnd, [...mFormatting, formatting]));
        } else {
          merged.add((mStart, mEnd, [...mFormatting, formatting]));
        }
      } else {
        // start > mStart (already enforced cause if)
        merged.add((mStart, start, mFormatting));

        if (end < mEnd) {
          merged.add((start, end, [...mFormatting, formatting]));
          merged.add((end, mEnd, mFormatting));
        } else if (end > mEnd) {
          merged.add((start, mEnd, [...mFormatting, formatting]));
        } else {
          merged.add((start, mEnd, [...mFormatting, formatting]));
        }
      }

      start = mEnd;
    }

    return merged;
  }
}
