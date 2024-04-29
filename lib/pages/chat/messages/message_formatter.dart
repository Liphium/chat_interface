import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';

class MessageFormatter {
  final TextStyle normalStyle;
  final TextStyle formattedStyle;

  MessageFormatter(this.normalStyle, this.formattedStyle);

  final RegExp emojiRegex = RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

  List<TextSpan> _parseWithEmojis(String text, TextStyle style) {
    final emojiStyle = style.copyWith(
      fontFamily: "Emoji",
    );

    var current = TextSpan(style: style);
    var textSpans = <TextSpan>[];
    for (var char in text.characters) {
      if (emojiRegex.hasMatch(char)) {
        textSpans.add(current);
        textSpans.add(TextSpan(text: char, style: emojiStyle));
        current = TextSpan(text: "", style: style);
      } else {
        current = TextSpan(text: (current.text ?? "") + char, style: current.style);
      }
    }
    if (current.text != null && current.text!.isNotEmpty) {
      textSpans.add(current);
    }

    return textSpans;
  }

  TextSpan build(String text) {
    // Parse the text into smaller spans that include the respective text styles
    final parsedText = <TextSpan>[];

    final pattern = RegExp("\\*\\*\\*(.*?)\\*\\*\\*|\\*\\*(.*?)\\*\\*|\\*(.*?)\\*|~~(.*?)~~");
    var currentStart = 0;
    for (var match in pattern.allMatches(text)) {
      if (match.start > currentStart) {
        parsedText.addAll(_parseWithEmojis(text.substring(currentStart, match.start), normalStyle));
      }
      final matchedString = text.substring(match.start, match.end);
      currentStart = match.end;

      // Check for the respective patterns and apply text styles
      if (matchedString.startsWith("***") && matchedString.length != 3) {
        // Bold and italic
        parsedText.add(TextSpan(text: text.substring(match.start, match.start + 3), style: formattedStyle));
        parsedText.addAll(_parseWithEmojis(
          text.substring(match.start + 3, match.end - 3),
          normalStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ));
        parsedText.add(TextSpan(text: text.substring(match.end - 3, match.end), style: formattedStyle));
      } else if (matchedString.startsWith("**") && matchedString.length != 2) {
        // Bold
        parsedText.add(TextSpan(text: text.substring(match.start, match.start + 2), style: formattedStyle));
        parsedText.addAll(_parseWithEmojis(
          text.substring(match.start + 2, match.end - 2),
          normalStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ));
        parsedText.add(TextSpan(text: text.substring(match.end - 2, match.end), style: formattedStyle));
      } else if (matchedString.startsWith("*")) {
        // Italic
        parsedText.add(TextSpan(text: text.substring(match.start, match.start + 1), style: formattedStyle));
        parsedText.addAll(_parseWithEmojis(
          text.substring(match.start + 1, match.end - 1),
          normalStyle.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ));
        parsedText.add(TextSpan(text: text.substring(match.end - 1, match.end), style: formattedStyle));
      } else if (matchedString.startsWith("~~")) {
        // Stroke
        parsedText.add(TextSpan(text: text.substring(match.start, match.start + 2), style: formattedStyle));
        parsedText.addAll(_parseWithEmojis(
          text.substring(match.start + 2, match.end - 2),
          normalStyle.copyWith(
            decoration: TextDecoration.lineThrough,
          ),
        ));
        parsedText.add(TextSpan(text: text.substring(match.end - 2, match.end), style: formattedStyle));
      }
    }
    parsedText.addAll(_parseWithEmojis(text.substring(currentStart, text.length), normalStyle));

    return TextSpan(children: parsedText, style: normalStyle);
  }
}

/// This thing parsed all the markdown syntax and emojis we have in the text input field
class FormattedTextEditingController extends TextEditingController {
  late final MessageFormatter formatter;

  FormattedTextEditingController(TextStyle normalStyle, TextStyle formattedStyle) {
    formatter = MessageFormatter(normalStyle, formattedStyle);
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    return formatter.build(text);
  }
}
