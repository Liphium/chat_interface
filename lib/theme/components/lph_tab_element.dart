import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class LPHTabElement extends StatefulWidget {
  final FlutterSignal<int>? selected;
  final List<String> tabs;
  final Function(String) onTabSwitch;

  const LPHTabElement({super.key, required this.tabs, required this.onTabSwitch, this.selected});

  @override
  State<LPHTabElement> createState() => _LPHTabElementState();
}

class _LPHTabElementState extends State<LPHTabElement> {
  late Signal<int> _selected;
  bool _createdHere = false;

  // The width of all the text in the tabs
  final _tabWidth = <int, double>{};

  @override
  void initState() {
    // Initialize the signal responsible for the state
    if (widget.selected == null) {
      _createdHere = true;
    }
    _selected = widget.selected ?? signal(0);

    // Measure all the texts
    int count = 0;
    for (var tab in widget.tabs) {
      final textPainter = TextPainter(
        text: TextSpan(text: tab, style: Get.textTheme.titleMedium),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      _tabWidth[count] = textPainter.size.width + defaultSpacing * 2;
      count++;
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_createdHere) {
      _selected.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Watch.builder(
          builder: (context) {
            // Calculate where the background should be placed
            double left = 0;
            int count = 0;
            for (var _ in widget.tabs) {
              if (count == _selected.value) {
                break;
              }
              left += _tabWidth[count]! + defaultSpacing;
              count++;
            }

            // Render the background with animation
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubicEmphasized,
              left: left,
              width: _tabWidth[_selected.value],
              height: Get.textTheme.titleMedium!.fontSize! * 1.5 + elementSpacing * 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(defaultSpacing),
                ),
              ),
            );
          },
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.tabs.length, (index) {
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : defaultSpacing),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_selected.value != index) {
                      widget.onTabSwitch(widget.tabs[index]);
                    }
                    _selected.value = index;
                  },
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: elementSpacing),
                    child: Watch(
                      (context) => Text(
                        widget.tabs[index],
                        style: Get.textTheme.titleMedium!.copyWith(
                          color: _selected.value == index ? Colors.white : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
