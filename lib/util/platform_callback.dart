import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class PlatformCallback extends StatefulWidget {
  final Function()? mobile;
  final Function()? desktop;
  final bool preventDoubleCalling;
  final Widget child;

  const PlatformCallback({super.key, this.mobile, this.desktop, this.preventDoubleCalling = true, required this.child});

  @override
  State<PlatformCallback> createState() => _PlatformCallbackState();
}

class _PlatformCallbackState extends State<PlatformCallback> {
  bool _openedOnMobile = false;
  bool _called = false;

  @override
  void initState() {
    _openedOnMobile = isMobileMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_called) {
          return widget.child;
        }

        final mobile = isMobileMode();
        if (mobile && !_openedOnMobile) {
          _called = widget.preventDoubleCalling;
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            widget.mobile?.call();
          });
        } else if (!mobile && _openedOnMobile) {
          _called = widget.preventDoubleCalling;
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            widget.desktop?.call();
          });
        }

        return widget.child;
      },
    );
  }
}
