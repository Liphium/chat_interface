import 'dart:math';

import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class GridCoordinate {
  final int x;
  final int y;

  const GridCoordinate(this.x, this.y);
}

class WordgridGrid extends StatefulWidget {
  final int gridSize;
  final double fontSize;

  const WordgridGrid(
      {super.key, required this.fontSize, required this.gridSize});

  @override
  State<WordgridGrid> createState() => _KanagridGridState();
}

class _KanagridGridState extends State<WordgridGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final selected = Rx<GridCoordinate?>(null);
  GridCoordinate? swapping;
  final swap = false.obs;
  final value = 0.0.obs;

  final alphabet = "abcdefghijklmnopqrstuvwxyz";
  final grid = <List<String>>[].obs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 500.ms);
    grid.value = List.generate(
        widget.gridSize,
        (x) => List.generate(
            widget.gridSize,
            (y) => alphabet[Random.secure().nextInt(alphabet.length)]
                .toUpperCase()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultSpacing),
        color: Get.theme.colorScheme.primaryContainer,
      ),
      padding: const EdgeInsets.all(defaultSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.gridSize, (x) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.gridSize, (y) {
              return RepaintBoundary(
                child: Obx(() {
                  final letter = grid[x][y];
                  final isSelected =
                      selected.value?.x == x && selected.value?.y == y;
                  final isNeighbor = selected.value != null &&
                      (selected.value!.x - x).abs() <= 1 &&
                      (selected.value!.y - y).abs() <= 1;

                  if (swap.value && isSelected) {
                    return RepaintBoundary(
                      child: Obx(() {
                        final diffX = swapping!.x - x;
                        final diffY = swapping!.y - y;
                        final offX =
                            diffX * value.value * widget.fontSize * 1.5 +
                                elementSpacing * 2 * diffX;
                        final offY =
                            diffY * value.value * widget.fontSize * 1.5 +
                                elementSpacing * 2 * diffY;

                        return Transform.translate(
                            offset: Offset(offY, offX),
                            child: renderLetter(
                                isSelected, isNeighbor, letter, () => {}));
                      }),
                    );
                  }

                  if (swap.value && swapping?.x == x && swapping?.y == y) {
                    return RepaintBoundary(
                      child: Obx(() {
                        final diffX = selected.value!.x - x;
                        final diffY = selected.value!.y - y;
                        final offX =
                            diffX * value.value * widget.fontSize * 1.5 +
                                elementSpacing * 2 * diffX;
                        final offY =
                            diffY * value.value * widget.fontSize * 1.5 +
                                elementSpacing * 2 * diffY;

                        return Transform.translate(
                            offset: Offset(offY, offX),
                            child: renderLetter(
                                isSelected, isNeighbor, letter, () => {}));
                      }),
                    );
                  }

                  return renderLetter(isSelected, isNeighbor, letter, () {
                    if (swap.value) {
                      return;
                    }
                    if (selected.value != null) {
                      if (isSelected) {
                        selected.value = null;
                        return;
                      }
                      if (!isNeighbor) {
                        selected.value = GridCoordinate(x, y);
                        return;
                      }
                      _controller.value = 0;
                      swapping = GridCoordinate(x, y);
                      swap.value = true;
                      _controller.animateTo(1.0,
                          curve: Curves.ease, duration: 500.ms);
                      _controller.addListener(updateAnimation);
                      return;
                    }
                    selected.value = GridCoordinate(x, y);
                  });
                }),
              );
            }),
          );
        }),
      ),
    ));
  }

  void updateAnimation() {
    value.value = _controller.value;
    if (_controller.isCompleted) {
      _controller.removeListener(updateAnimation);
      swapInGrid(selected.value!, swapping!);
      swap.value = false;
      swapping = null;
      selected.value = null;
    }
  }

  void swapInGrid(GridCoordinate a, GridCoordinate b) {
    final temp = grid[a.x][a.y];
    grid[a.x][a.y] = grid[b.x][b.y];
    grid[b.x][b.y] = temp;
    grid.refresh();
  }

  Widget renderLetter(
      bool isSelected, bool isNeighbor, String letter, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.all(elementSpacing),
      child: SizedBox(
        width: widget.fontSize * 1.5,
        height: widget.fontSize * 1.5,
        child: Material(
          borderRadius: BorderRadius.circular(defaultSpacing),
          color: isSelected
              ? Get.theme.colorScheme.primary
              : isNeighbor
                  ? Get.theme.colorScheme.onTertiary
                  : Get.theme.colorScheme.onBackground,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(defaultSpacing),
            child: Center(
                child: Text(
              letter,
              style: Get.theme.textTheme.labelMedium!.copyWith(
                fontSize: widget.fontSize,
              ),
              textHeightBehavior: noTextHeight,
            )),
          ),
        ),
      ),
    );
  }
}
