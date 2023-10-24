import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class ErrorContainer extends StatelessWidget {

  /// Translation required
  final String message;

  /// Translation required
  final String description;

  const ErrorContainer({super.key, required this.message, required this.description});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          horizontalSpacing(defaultSpacing),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: theme.colorScheme.onSurface
                )),
                verticalSpacing(defaultSpacing * 0.5),
                Text(description, style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface
                )),
              ],
            ),
          )
        ],
      ),
    );
  }
}