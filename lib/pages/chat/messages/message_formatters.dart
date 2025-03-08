import 'dart:math';

import 'package:chat_interface/pages/chat/messages/message_automaton.dart';
import 'package:chat_interface/util/logging_framework.dart';

class BoldItalicAutomaton extends PatternAutomaton {
  int _stars = 0;
  bool _inPattern = false;
  List<TextFormattingType> _current = [];

  @override
  void resetState() {
    _stars = 0;
    _inPattern = false;
    _current = [];
    super.resetState();
  }

  @override
  (bool, bool, bool, List<TextFormattingType>) evaluate(String prevChar, String char) {
    // Check for star characters
    if (char == '*') {
      // If the previous char wasn't a star, we're changing modes
      if (prevChar != "*") {
        _inPattern = !_inPattern;
      }

      // When we're inside the pattern, adjust the outputted formatting
      if (_inPattern) {
        _stars = min(_stars + 1, 3);
        if (_stars == 1) {
          _current = [TextFormattingType.italic];
        } else if (_stars == 2) {
          _current = [TextFormattingType.bold];
        } else if (_stars == 3) {
          _current = [TextFormattingType.bold, TextFormattingType.italic];
        }
      } else {
        _stars--;
        _current = [];
      }

      return (true, _stars == 0, false, _current);
    } else {
      // The pattern is invalid we're outside and the right amount of stars weren't escaped
      if (!_inPattern) {
        final invalid = _stars != 0;
        _stars = 0;
        return (false, false, invalid, _current); // Only return valid when there are no stars left
      }

      // The pattern is valid as long as nothing happens
      return (false, false, false, _current);
    }
  }
}

class StrikethroughAutomaton extends PatternAutomaton {
  int _squiggles = 0;
  bool _inPattern = false;

  @override
  void resetState() {
    _squiggles = 0;
    _inPattern = false;
    super.resetState();
  }

  @override
  (bool, bool, bool, List<TextFormattingType>) evaluate(String prevChar, String char) {
    // Check for squiggle characters
    if (char == '~') {
      // If the previous char wasn't a squiggle, we're changing modes
      if (prevChar != "~") {
        _inPattern = !_inPattern;
      }

      // When we're inside the pattern, adjust the outputted formatting
      if (_inPattern) {
        _squiggles = min(_squiggles + 1, 2);
        return (true, false, false, [TextFormattingType.lineThrough]);
      } else {
        _squiggles--;
      }

      return (true, _squiggles == 0, false, [TextFormattingType.lineThrough]);
    } else {
      // The pattern is invalid we're outside and the right amount of squiggles weren't escaped
      if (!_inPattern) {
        final invalid = _squiggles != 0;
        _squiggles = 0;
        return (false, false, invalid, []); // Only return valid when there are no squiggles left
      }

      // The pattern is valid as long as nothing happens
      return (false, false, false, [TextFormattingType.lineThrough]);
    }
  }
}

class UnderlineAutomaton extends PatternAutomaton {
  int _underscores = 0;
  bool _inPattern = false;

  @override
  void resetState() {
    _underscores = 0;
    _inPattern = false;
    super.resetState();
  }

  @override
  (bool, bool, bool, List<TextFormattingType>) evaluate(String prevChar, String char) {
    // Check for underscore characters
    if (char == "_") {
      // If the previous char wasn't an underscore, we're changing modes
      if (prevChar != "_") {
        _inPattern = !_inPattern;
      }

      if (_inPattern) {
        _underscores = min(_underscores + 1, 1);
        sendLog("detected");
        return (true, false, false, [TextFormattingType.underline]);
      } else {
        _underscores--;
      }

      return (true, _underscores == 0, false, [TextFormattingType.underline]);
    } else {
      // The pattern is invalid we're outside and the right amount of underscores weren't escaped
      if (!_inPattern) {
        final invalid = _underscores != 0;
        _underscores = 0;
        return (false, false, invalid, []); // Only return valid when there are no underscores left
      }

      // The pattern is valid as long as nothing happens
      return (false, false, false, [TextFormattingType.underline]);
    }
  }
}
