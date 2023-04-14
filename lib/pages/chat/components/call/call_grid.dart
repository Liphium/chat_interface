import 'dart:math';

import 'package:chat_interface/pages/chat/components/call/call_rectangle.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class CallGridView extends StatefulWidget {

  final BoxConstraints constraints;
  final int people = 10;

  const CallGridView({super.key, required this.constraints});

  @override
  State<CallGridView> createState() => _CallGridViewState();
}

class _CallGridViewState extends State<CallGridView> {

  final double _minWidth = 250, _minHeight = 140;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);


    double computedHeight = _calculateSmallRectangleHeight(widget.constraints.maxWidth, widget.constraints.maxHeight, widget.people);
    computedHeight -= defaultSpacing * widget.people;

    return 
    
    computedHeight > _minHeight ?
    Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        direction: Axis.horizontal,
        spacing: defaultSpacing * 1.5,
        runSpacing: defaultSpacing * 1.5,
      
        children: getParticipants(regtangularCallMembers, theme, 0, 0, BoxConstraints(
          maxHeight: max(_minHeight, computedHeight),
        ), widget.people),
      ),
    ) :
    
    SingleChildScrollView(
      padding: const EdgeInsets.all(defaultSpacing),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        direction: Axis.horizontal,
        spacing: defaultSpacing * 1.5,
        runSpacing: defaultSpacing * 1.5,
      
        children: getParticipants(regtangularCallMembers, theme, 0, 0, BoxConstraints(
          maxHeight: max(_minHeight, computedHeight),
        ), widget.people),
      ),
    );
  }

  double _calculateSmallRectangleHeight(double bigRectangleWidth, double bigRectangleHeight, int n) {
    double aspectRatio = 16 / 9;
    int columns = sqrt(n).ceil();
    int rows = (n / columns).ceil();
    double smallRectangleWidth = bigRectangleWidth / columns;
    double smallRectangleHeight = smallRectangleWidth / aspectRatio;
    if (smallRectangleHeight * rows > bigRectangleHeight) {
      smallRectangleHeight = bigRectangleHeight / rows;
      smallRectangleWidth = smallRectangleHeight * aspectRatio;
    }
    print('Small rectangle width: $smallRectangleWidth');
    print('Small rectangle height: $smallRectangleHeight');

    return smallRectangleHeight;
  }
}