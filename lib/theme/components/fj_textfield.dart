import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class FJTextField extends StatefulWidget {

  final bool obscureText;
  final bool animation;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;

  const FJTextField({super.key, this.controller, this.hintText, this.errorText, this.animation = true, this.obscureText = false});

  @override
  State<FJTextField> createState() => _FJTextFieldState();
}

class _FJTextFieldState extends State<FJTextField> {

  final _node = FocusNode();
  final _focus = false.obs;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    _node.addListener(() {
      _focus.value = _node.hasFocus;
    });

    return Obx(() => Animate(
      effects: [
        ScaleEffect(
          end: const Offset(1.08, 1.08),
          duration: 250.ms,
          curve: Curves.ease
        ),
        CustomEffect(
          begin: 0,
          end: 1,
          duration: 250.ms,
          builder: (context, value, child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: defaultSpacing * value),
              child: child
            );
          },
        )
      ],
      target: _focus.value && widget.animation ? 1 : 0,
      child: Material(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(defaultSpacing),
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hintText,
              labelStyle: theme.textTheme.labelLarge,
              errorText: widget.errorText,
              border: InputBorder.none,
            ),
            style: theme.textTheme.labelLarge,
            obscureText: widget.obscureText,
            autocorrect: false,
            enableSuggestions: false,
            controller: widget.controller,
            onTap: () => _focus.value = true,
            focusNode: _node,
          ),
        ),
      ),
    ));
  }
}