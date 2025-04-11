import 'dart:math';

import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class SizeDemo extends StatelessWidget {
  const SizeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const n = 5;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the available height for every participant
        double computedHeight = calculateMaxChildHeight(Size(constraints.biggest.width, constraints.biggest.height), n);
        computedHeight -= defaultSpacing * n;

        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            direction: Axis.horizontal,
            spacing: defaultSpacing * 1.5,
            runSpacing: defaultSpacing * 1.5,
            children: List.generate(
              n,
              (index) => ConstrainedBox(
                constraints: BoxConstraints(maxHeight: computedHeight),
                child: AspectRatio(aspectRatio: 16 / 9, child: Container(color: Colors.primaries[index % Colors.primaries.length])),
              ),
            ),
          ),
        );
      },
    );
  }

  double calculateMaxChildHeight(Size parentSize, int numChildren) {
    // Do it for the height
    double idealHeight = parentSize.height;
    double childrenWidth = parentSize.height * (16.0 / 9.0);
    int numFit = 0;
    int lastNumFit = numFit;
    while (idealHeight * (numChildren - numFit) > parentSize.height) {
      idealHeight -= 1;
      childrenWidth = idealHeight * (16.0 / 9.0);
      numFit = (parentSize.width ~/ childrenWidth).ceil() - 1;
      if (numFit != lastNumFit) {
        lastNumFit = numFit;
        sendLog(numFit);
      }
    }

    sendLog("Ideal height: $idealHeight");

    return idealHeight;
  }

  double helloWorld(Size parentSize, int childCount) {
    // Calculate ideal child height based on 16:9 aspect ratio
    double idealHeight = parentSize.width * (9.0 / 16.0);

    // Calculate maximum available height considering child count
    double availableHeight = parentSize.height / childCount;

    // Return the smaller of ideal height and available height
    return min(idealHeight, availableHeight);
  }
}
