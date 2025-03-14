import 'dart:math';

import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class SpaceGridRenderer extends StatelessWidget {
  /// The amount of widgets that should fit into the grid
  final int amount;

  /// Renders the individual widgets (size will be applied)
  final Widget Function(int) renderer;

  /// The padding between the rectangles
  final double padding;

  const SpaceGridRenderer({
    super.key,
    required this.amount,
    this.padding = defaultSpacing,
    required this.renderer,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = 16 / 9;
        final maxWidth = constraints.maxWidth - padding;
        final maxHeight = constraints.maxHeight - padding;
        double bestSize = 0;

        // Compute the optimal width for the children
        for (int c = 1; c <= amount; c++) {
          final r = (amount + c - 1) ~/ c;
          final maxChildWidth = maxWidth / c;
          final maxChildHeight = maxHeight / r;
          final childWidth = maxChildWidth < maxChildHeight * ratio ? maxChildWidth : maxChildHeight * ratio;
          if (childWidth > bestSize) {
            bestSize = childWidth;
          }
        }

        final childWidth = max(bestSize, 300);

        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(padding / 2),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(
                  amount,
                  (index) {
                    if (index >= amount) return const SizedBox();
                    return Padding(
                      padding: EdgeInsets.all(padding / 2),
                      child: SizedBox(
                        width: childWidth - padding * 2,
                        height: (childWidth - padding * 2) / ratio,
                        child: renderer.call(index),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
