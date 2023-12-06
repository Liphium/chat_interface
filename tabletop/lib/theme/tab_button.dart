import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class TabButton extends StatefulWidget {
  final Function() onTap;
  final String label;
  final RxString selected;
  final BorderRadius radius;

  const TabButton(
      {super.key,
      required this.onTap,
      required this.label,
      this.radius = const BorderRadius.all(Radius.circular(defaultSpacing)),
      required this.selected});

  @override
  State<TabButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<TabButton> with TickerProviderStateMixin {

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
      if (value == widget.label) {
        _controller.loop(count: 1, reverse: true);
      }
    });

    return Animate(
      controller: _controller,
      effects: [
        ScaleEffect(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0), 
          curve: Curves.easeIn, 
          duration: 100.ms
        )
      ],
      child: Obx(() => Material(
            borderRadius: widget.radius,
            color: widget.selected.value == widget.label
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
            child: InkWell(
              borderRadius: widget.radius,
              onTap: () {
                widget.onTap();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultSpacing * 1.5,
                    vertical: defaultSpacing * 0.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  widget.label.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          )),
    );
  }
}
