import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingIconButton extends StatelessWidget {

  final RxBool loading;
  final IconData icon;
  final Color? color;
  final Function() onTap;

  const LoadingIconButton({super.key, required this.loading, required this.onTap, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        borderRadius: BorderRadius.circular(50),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () => loading.value ? null : onTap(),
          child: Padding(
            padding: const EdgeInsets.all(defaultSpacing),
            child: Obx(() => loading.value ? 
            const Padding(
              padding: EdgeInsets.all(defaultSpacing * 0.25),
              child: CircularProgressIndicator(strokeWidth: 3.0,),
            ) : 
            Icon(icon, color: color ?? Colors.white, size: 23),
            ),
          ),
        ),
      ),
    );
  }
}