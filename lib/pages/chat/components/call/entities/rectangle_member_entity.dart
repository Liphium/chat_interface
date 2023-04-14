import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class RectangleMemberEntity extends StatefulWidget {

  final double bottomPadding;
  final double rightPadding;

  const RectangleMemberEntity({super.key, this.bottomPadding = 0, this.rightPadding = 0});

  @override
  State<RectangleMemberEntity> createState() => _RectangleMemberEntityState();
}

class _RectangleMemberEntityState extends State<RectangleMemberEntity> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomPadding, right: widget.rightPadding),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(defaultSpacing),
            border: Border.all(color: Colors.green, width: 2),
          ),
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            height: 25,
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing * 0.5),
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(defaultSpacing),
                )
              )
            ),
          )
        ),
      ),
    );
  }
}