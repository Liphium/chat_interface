import 'dart:math';

import 'package:chat_interface/pages/chat/messages/message_automaton.dart';
import 'package:flutter/material.dart';

class TextEvaluator {
  final automatons = [BoldItalicAutomaton(), StrikethroughAutomaton(), UnderlineAutomaton()];

  /// Evaluate a text with a start style of [startStyle].
  /// Optionally provide a text style for the formatting patterns.
  ///
  /// Returns a list of text spans that are formatted properly.
  List<TextSpan> evaluate(
    String text,
    TextStyle startStyle, {
    TextStyle? pattern,
    bool skipPatterns = false,
  }) {
    // Reset the state of the automatons
    for (var automaton in automatons) {
      /*
      // Add logging to any automaton like this (in case tests fail or sth)
      if (automaton is BoldItalicAutomaton) {
        automaton.logging = true;
      }
      */

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
    List<(int, int, List<TextFormattingType>)> ranges = [];
    for (var automaton in automatons) {
      if (ranges.isEmpty) {
        // If nothing is there yet, add all the ranges from the automaton (shouldn't have overlaps)
        for (var (start, end, formatting) in automaton.getResult()) {
          // Only add if it's a valid range
          if (end >= start) {
            ranges.add((start, end, formatting));
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
        spans.add(TextSpan(text: text.substring(lastEnd, start), style: startStyle));
      }

      // Build the formatting for the range
      bool skip = false;
      TextStyle style = startStyle;
      for (var format in formattings) {
        if (format == TextFormattingType.pattern && skipPatterns) {
          skip = true;
          break;
        }
        style = format.apply(style, pattern: pattern);
      }

      // Add the range itself
      if (!skip) {
        spans.add(TextSpan(text: text.substring(start, min(end, text.length)), style: style));
      }
      lastEnd = end;
    }

    // Add the rest of the text (in case necessary)
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd, text.length), style: startStyle));
    }

    return spans;
  }

  /// Merge a range with text formatting ([toAdd]) into a non-overlapping set of base ([ranges]) ranges.
  ///
  /// Returns the merged ranges (also non-overlapping).
  List<(int, int, List<TextFormattingType>)> mergeRanges(
    (int, int, List<TextFormattingType>) toAdd,
    List<(int, int, List<TextFormattingType>)> ranges,
  ) {
    List<(int, int, List<TextFormattingType>)> merged = [];

    var (start, end, formatting) = toAdd;
    for (var (mStart, mEnd, mFormatting) in ranges) {
      // Add the rest if current range is already past it
      if (start < end && mStart > end && start < end) {
        merged.add((start, end, formatting));
        start = end;
      }

      // Check if they are overlapping
      if (mEnd < start || mStart > end || start >= end) {
        merged.add((mStart, mEnd, mFormatting));
        continue;
      }

      if (start <= mStart) {
        if (start != mStart) {
          merged.add((start, mStart, formatting));
        }
        if (end <= mEnd) {
          if (mStart != end) {
            merged.add((mStart, end, [...mFormatting, ...formatting]));
          }
          if (end != mEnd) {
            merged.add((end, mEnd, mFormatting));
          }
        } else if (end > mEnd) {
          merged.add((mStart, mEnd, [...mFormatting, ...formatting]));
        } else {
          merged.add((mStart, mEnd, [...mFormatting, ...formatting]));
        }
      } else {
        // start > mStart (already enforced cause if)
        merged.add((mStart, start, mFormatting));

        if (end < mEnd) {
          merged.add((start, end, [...mFormatting, ...formatting]));
          merged.add((end, mEnd, mFormatting));
        } else if (end >= mEnd && start != mEnd) {
          merged.add((start, mEnd, [...mFormatting, ...formatting]));
        }
      }

      start = mEnd;
    }

    // Add rest, if not added by merge operation
    if (start < end) {
      merged.add((start, end, formatting));
    }

    return merged;
  }
}

class MessageFormatter {
  final TextStyle normalStyle;
  final TextStyle? formattedStyle;
  final evaluator = TextEvaluator();

  MessageFormatter(this.normalStyle, this.formattedStyle);

  /// Build a text span from a text by parsing the formatting patterns in it.
  TextSpan build(String text) {
    return TextSpan(
      children: evaluator.evaluate(
        text,
        normalStyle,
        pattern: formattedStyle,
        skipPatterns: formattedStyle == null,
      ),
      style: normalStyle,
    );
  }
}

/// This thing parsed all the markdown syntax and emojis we have in the text input field
class FormattedTextEditingController extends TextEditingController {
  late final MessageFormatter formatter;

  FormattedTextEditingController(TextStyle normalStyle, TextStyle formattedStyle) {
    formatter = MessageFormatter(normalStyle, formattedStyle);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    return formatter.build(text);
  }
}

/// Widget to display formatting directives
class FormattedText extends StatefulWidget {
  final String text;
  final TextStyle baseStyle;
  final TextStyle? formatStyle;

  const FormattedText({super.key, required this.text, required this.baseStyle, this.formatStyle});

  @override
  State<FormattedText> createState() => _FormattedTextState();
}

class _FormattedTextState extends State<FormattedText> {
  late TextSpan formatted;

  @override
  void initState() {
    formatted = MessageFormatter(widget.baseStyle, widget.formatStyle).build(widget.text);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FormattedText oldWidget) {
    formatted = MessageFormatter(widget.baseStyle, widget.formatStyle).build(widget.text);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(formatted);
  }
}
