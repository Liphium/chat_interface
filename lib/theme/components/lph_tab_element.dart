import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LPHTabElement extends StatefulWidget {
  final RxInt? selected;
  final List<String> tabs;
  final Function(String) onTabSwitch;

  const LPHTabElement({
    super.key,
    required this.tabs,
    required this.onTabSwitch,
    this.selected,
  });

  @override
  State<LPHTabElement> createState() => _LPHTabElementState();
}

class _LPHTabElementState extends State<LPHTabElement> {
  RxInt _selected = 0.obs;

  // The width of all the text in the tabs
  final tabWidth = <int, double>{};

  @override
  void initState() {
    // Measure all the texts
    _selected = widget.selected ?? 0.obs;
    int count = 0;
    for (var tab in widget.tabs) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: tab,
          style: Get.textTheme.titleMedium,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      tabWidth[count] = textPainter.size.width + defaultSpacing * 2;
      count++;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(defaultSpacing),
      ),
      padding: const EdgeInsets.all(elementSpacing * 1.5),
      child: Stack(
        children: [
          Obx(() {
            double left = 0;
            int count = 0;
            for (var _ in widget.tabs) {
              if (count == _selected.value) {
                break;
              }
              left += tabWidth[count]! + elementSpacing;
              count++;
            }

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubicEmphasized,
              left: left,
              width: tabWidth[_selected.value],
              height: Get.textTheme.titleMedium!.fontSize! * 1.5 + elementSpacing * 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(defaultSpacing),
                ),
              ),
            );
          }),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.tabs.length, (index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : elementSpacing),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultSpacing,
                        vertical: elementSpacing,
                      ),
                      child: Text(
                        widget.tabs[index],
                        style: Get.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
