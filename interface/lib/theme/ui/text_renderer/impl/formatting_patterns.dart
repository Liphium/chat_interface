
import 'package:chat_interface/theme/ui/text_renderer/text_pattern_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class BoldPattern extends TextPattern {
  
  BoldPattern() : super('**');

  @override
  TextStyle process(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }
}

class ItalicPattern extends TextPattern {
  
  ItalicPattern() : super('*');

  @override
  TextStyle process(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }
}

class UnderlinePattern extends TextPattern {
  
  UnderlinePattern() : super('_');

  @override
  TextStyle process(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.underline,
      decorationThickness: 4,
      decorationColor: style.color,
    );
  }
}

class StrokePattern extends TextPattern {
  
  StrokePattern() : super('~');

  @override
  TextStyle process(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.lineThrough,
      decorationThickness: 4,
      decorationColor: style.color,
    );
  }
}

class TrollPattern extends TextPattern {
  
  TrollPattern() : super('---');

  @override
  TextStyle process(TextStyle style) {
    return style.copyWith(
      letterSpacing: defaultSpacing * 0.5,
    );
  }
}