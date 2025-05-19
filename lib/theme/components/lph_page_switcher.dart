import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class LPHPageSwitcher extends StatelessWidget {
  final Signal<int> currentPage;
  final Signal<int> count;
  final Signal<bool> loading;
  final Function(int) page;

  const LPHPageSwitcher({
    super.key,
    required this.currentPage,
    required this.count,
    required this.loading,
    required this.page,
  });

  int getMaxPage() => (count.value / 20).ceil();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LoadingIconButton(
          loading: loading,
          onTap: () {
            if (currentPage.value == 0) {
              return;
            }
            page(0);
          },
          icon: Icons.skip_previous,
        ),
        horizontalSpacing(elementSpacing),
        LoadingIconButton(
          loading: loading,
          onTap: () {
            if (currentPage.value == 0) {
              return;
            }
            page(currentPage.value - 1);
          },
          icon: Icons.arrow_back,
        ),
        const Spacer(),
        Watch(
          (ctx) => Text(
            "page_switcher".trParams({"count": (currentPage.value + 1).toString(), "max": getMaxPage().toString()}),
            style: Get.textTheme.labelLarge,
          ),
        ),
        const Spacer(),
        LoadingIconButton(
          loading: loading,
          onTap: () {
            if (currentPage.value == getMaxPage() - 1) {
              return;
            }
            page(currentPage.value + 1);
          },
          icon: Icons.arrow_forward,
        ),
        horizontalSpacing(elementSpacing),
        LoadingIconButton(
          loading: loading,
          onTap: () {
            if (currentPage.value == getMaxPage() - 1) {
              return;
            }
            page(getMaxPage() - 1);
          },
          icon: Icons.skip_next,
        ),
      ],
    );
  }
}
