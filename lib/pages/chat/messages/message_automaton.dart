import 'dart:math';

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
        return base.copyWith(
          decoration: TextDecoration.combine([
            base.decoration ?? TextDecoration.none,
            TextDecoration.underline,
          ]),
        );
      case TextFormattingType.lineThrough:
        return base.copyWith(
          decoration: TextDecoration.combine([
            base.decoration ?? TextDecoration.none,
            TextDecoration.lineThrough,
          ]),
        );
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
      _count = max(_currentState.length - 1, 0);
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
        sendLog("$char | start valid=$valid invalid=$invalid count=$_count");
      }
      _currentState.add((index, index + 1, formatting));
    } else {
      if (logging) {
        sendLog(_count);
      }
      final (currStart, currEnd, currFmt) = _currentState[_count];

      // If there is no new formatting, leave it be and add the current thing on top
      if (listEquals(currFmt, formatting)) {
        if (logging) {
          sendLog("$char | add existing $valid $invalid $_count");
        }

        _currentState[_count] = (currStart, currEnd + 1, currFmt);
      } else {
        if (logging) {
          sendLog("$char | add new $valid $invalid $_count");
        }

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
    _currentStart = 0;
    _incremented = false;
  }

  /// Evaluate an automaton for one char and the previous one.
  ///
  /// The first element is whether the element was matched by the automaton.
  /// The second element is whether or not the entire pattern that was just matched is invalid.
  /// The third element is whether a snapshot should be saved and the pattern was valid.
  /// The fourth element are the currently active types of formatting.
  (bool, bool, bool, List<TextFormattingType>) evaluate(String prevChar, String char);
}

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
    // Close as invalid in case of termination symbol
    if (char == '' && _inPattern) {
      return (false, false, true, []);
    }

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

      return (true, false, false, _current);
    } else {
      // The pattern is invalid we're outside and the right amount of stars weren't escaped
      if (!_inPattern) {
        final invalid = _stars != 0;
        _stars = 0;
        return (
          false,
          !invalid,
          invalid,
          _current,
        ); // Only return valid when there are no stars left
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
    // Close as invalid in case of termination symbol
    if (char == '' && _inPattern) {
      return (false, false, true, []);
    }

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

      return (true, false, false, [TextFormattingType.lineThrough]);
    } else {
      // The pattern is invalid we're outside and the right amount of squiggles weren't escaped
      if (!_inPattern) {
        final invalid = _squiggles != 0;
        _squiggles = 0;
        return (false, !invalid, invalid, []); // Only return valid when there are no squiggles left
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
    // Close as invalid in case of termination symbol
    if (char == '' && _inPattern) {
      return (false, false, true, []);
    }

    // Check for underscore characters
    if (char == "_") {
      // If the previous char wasn't an underscore, we're changing modes
      if (prevChar != "_") {
        _inPattern = !_inPattern;
      }

      if (_inPattern) {
        _underscores = min(_underscores + 1, 2);
        return (true, false, false, [TextFormattingType.underline]);
      } else {
        _underscores--;
      }

      return (true, false, false, [TextFormattingType.underline]);
    } else {
      // The pattern is invalid we're outside and the right amount of underscores weren't escaped
      if (!_inPattern) {
        final invalid = _underscores != 0;
        _underscores = 0;
        return (
          false,
          !invalid,
          invalid,
          [],
        ); // Only return valid when there are no underscores left
      }

      // The pattern is valid as long as nothing happens
      return (false, false, false, [TextFormattingType.underline]);
    }
  }
}
