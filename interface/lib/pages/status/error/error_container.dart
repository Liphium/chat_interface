import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class ErrorContainer extends StatelessWidget {

  /// Translation required
  final String message;

  const ErrorContainer({super.key, required this.message});

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(defaultSpacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(defaultSpacing)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          horizontalSpacing(defaultSpacing),
          Text(message, style: Theme.of(context).textTheme.labelMedium)
        ],
      ),
    );
  }
}