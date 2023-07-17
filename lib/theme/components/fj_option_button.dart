import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class FJOptionButton extends StatefulWidget {

  final String text;
  final Function()? onTap;

  const FJOptionButton({super.key, required this.text, required this.onTap});

  @override
  State<FJOptionButton> createState() => _FJTextFieldState();
}

class _FJTextFieldState extends State<FJOptionButton> {

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.background,
      borderRadius: BorderRadius.circular(defaultSpacing),
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultSpacing),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.text, style: theme.textTheme.labelLarge)
              ),
              const Icon(Icons.arrow_forward)
            ],
          )
        ),
      ),
    );
  }
}