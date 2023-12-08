import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingIconButton extends StatelessWidget {

  final RxBool loading;
  final IconData icon;
  final Color? color;
  final String? tooltip;
  final double iconSize;
  final double padding;
  final Function() onTap;
  final Function(BuildContext)? onTapContext;

  const LoadingIconButton({super.key, required this.loading, required this.onTap, this.tooltip, this.onTapContext, required this.icon, this.color, this.iconSize = 23, this.padding = 0});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? "",
      child: SizedBox(
        width: iconSize+17+padding,
        height: iconSize+17+padding,
        child: Material(
          borderRadius: BorderRadius.circular(50),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              if(loading.value) {
                return;
              }
    
              onTap();
              if(onTapContext != null) {
                onTapContext!(context);
              }
            },
            hoverColor: Get.theme.hoverColor,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Obx(() => loading.value ? 
              Padding(
                padding: const EdgeInsets.all(defaultSpacing),
                child: CircularProgressIndicator(strokeWidth: 3.0, color: Get.theme.colorScheme.onPrimary),
              ) : 
              Icon(icon, color: color ?? Colors.white, size: iconSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}