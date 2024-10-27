import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SidebarIconButton extends StatefulWidget {
  final Function() onTap;
  final IconData icon;
  final int index;
  final RxInt selected;
  final BorderRadius radius;

  const SidebarIconButton(
      {super.key,
      required this.onTap,
      required this.icon,
      this.radius = const BorderRadius.all(Radius.circular(defaultSpacing)),
      required this.index,
      required this.selected});

  @override
  State<SidebarIconButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarIconButton> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.selected.listen((value) {
      if (widget.selected.value == widget.index) {
        _controller.loop(count: 1, reverse: true);
      }
    });

    return Animate(
      controller: _controller,
      effects: [ScaleEffect(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), curve: Curves.easeOut, duration: 120.ms)],
      child: Obx(
        () => Material(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(defaultSpacing),
            topRight: Radius.circular(defaultSpacing),
          ),
          color: widget.selected.value == widget.index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.inverseSurface,
          child: InkWell(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(defaultSpacing),
              topRight: Radius.circular(defaultSpacing),
            ),
            onTap: () {
              widget.onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: elementSpacing, horizontal: sectionSpacing),
              child:
                  Icon(widget.icon, color: widget.selected.value == widget.index ? Get.theme.colorScheme.onPrimary : Get.theme.colorScheme.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
