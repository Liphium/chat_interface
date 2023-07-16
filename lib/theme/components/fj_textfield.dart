import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class FJTextField extends StatefulWidget {

  final bool obscureText;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;

  const FJTextField({super.key, this.controller, this.hintText, this.errorText, this.obscureText = false});

  @override
  State<FJTextField> createState() => _FJTextFieldState();
}

class _FJTextFieldState extends State<FJTextField> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.onBackground,
      borderRadius: BorderRadius.circular(defaultSpacing),
      child: Padding(
        padding: const EdgeInsets.all(defaultSpacing),
        child: TextField(
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText,
            errorText: widget.errorText,
            filled: false,
            border: InputBorder.none
          ),
          style: theme.textTheme.labelLarge,
          obscureText: widget.obscureText,
          autocorrect: false,
          enableSuggestions: false,
          controller: widget.controller,
        ),
      ),
    );
  }
}