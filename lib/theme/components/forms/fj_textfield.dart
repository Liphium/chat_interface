import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class FJTextField extends StatefulWidget {
  final bool obscureText;
  final bool animation;
  final String? hintText;
  final String? errorText;
  final IconData? prefixIcon;
  // Uses the secondary background color instead of the primary
  final bool secondaryColor;
  final bool small;
  final TextEditingController? controller;
  final int? maxLength;
  final int maxLines;
  final bool autofocus;
  final bool autocorrect;
  final Function(String)? onChange;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;

  const FJTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.prefixIcon,
    this.errorText,
    this.animation = true,
    this.secondaryColor = false,
    this.small = false,
    this.obscureText = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.maxLines = 1,
    this.maxLength,
    this.onChange,
    this.onSubmitted,
    this.inputFormatters,
  });

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

    return Obx(
      () => Animate(
        effects: [
          ScaleEffect(end: const Offset(1.08, 1.08), duration: 250.ms, curve: Curves.ease),
          CustomEffect(
            begin: 0,
            end: 1,
            duration: 250.ms,
            builder: (context, value, child) {
              return Padding(padding: EdgeInsets.symmetric(horizontal: defaultSpacing * value), child: child);
            },
          )
        ],
        target: _focus.value && widget.animation ? 1 : 0,
        child: Material(
          color: widget.secondaryColor ? Get.theme.colorScheme.onInverseSurface : Get.theme.colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(defaultSpacing),
          child: Padding(
            padding: const EdgeInsets.all(defaultSpacing * 1.5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.prefixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: defaultSpacing, left: 0),
                    child: Icon(
                      widget.prefixIcon,
                      color: Get.theme.colorScheme.onPrimary,
                      size: (widget.small ? theme.textTheme.labelMedium : theme.textTheme.labelLarge)!.fontSize! * 1.5,
                    ),
                  ),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: widget.hintText,
                      labelStyle: widget.small ? theme.textTheme.labelMedium : theme.textTheme.labelLarge,
                      hintStyle: widget.small ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge,
                      errorText: widget.errorText,
                      border: InputBorder.none,
                      counterText: "",
                    ),
                    style: widget.small ? theme.textTheme.labelMedium : theme.textTheme.labelLarge,
                    obscureText: widget.obscureText,
                    autofocus: widget.autofocus,
                    autocorrect: widget.autocorrect,
                    maxLines: widget.maxLines,
                    enableSuggestions: false,
                    controller: widget.controller,
                    maxLength: widget.maxLength,
                    maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
                    onTap: () => _focus.value = true,
                    focusNode: _node,
                    onChanged: widget.onChange,
                    inputFormatters: widget.inputFormatters,
                    onSubmitted: widget.onSubmitted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
