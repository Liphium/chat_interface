import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CircleMemberEntity extends StatefulWidget {

  final double bottomPadding;
  final double rightPadding;

  const CircleMemberEntity({super.key, required this.bottomPadding, required this.rightPadding});

  @override
  State<CircleMemberEntity> createState() => _MemberEntityState();
}

class _MemberEntityState extends State<CircleMemberEntity> {
  
  final muted = false.obs;
  final audioMuted = false.obs;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomPadding, right: widget.rightPadding),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(200),
            ),
            child: Center(child: Text("test", style: theme.textTheme.bodyLarge))
          ),
    
          //* Muted indicator
          Obx(() =>
            Visibility(
              visible: muted.value,
              child: Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(200),
                  ),
                  width: 30,
                  height: 30,
                  child: const Center(
                    child: Icon(
                      Icons.mic_off,
                      color: Colors.white,
                    )
                  )
                ),
              ),
            ),
          ),
    
          //* Speaker indicator
          Obx(() =>
            Visibility(
              visible: audioMuted.value,
              child: Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(200),
                  ),
                  width: 30,
                  height: 30,
                  child: const Center(
                    child: Icon(
                      Icons.volume_off,
                      color: Colors.white,
                    )
                  )
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}