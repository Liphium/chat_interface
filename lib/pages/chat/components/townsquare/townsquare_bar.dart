import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TownsquareBar extends StatefulWidget {
  const TownsquareBar({super.key});

  @override
  State<TownsquareBar> createState() => _TownsquareBarState();
}

class _TownsquareBarState extends State<TownsquareBar> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Padding(
        padding: const EdgeInsets.all(defaultSpacing),
        child: Container(
          decoration: BoxDecoration(color: Get.theme.colorScheme.onInverseSurface, borderRadius: BorderRadius.circular(sectionSpacing)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: sectionSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpacing(sectionSpacing),

                  // The title of the page
                  Text("Townsquare", style: Theme.of(context).textTheme.titleLarge),
                  verticalSpacing(defaultSpacing * 0.5),

                  // All of the actions on townsquare
                  TownsquareBarButton(icon: Icons.edit, label: "Create"),
                  TownsquareBarButton(icon: Icons.dashboard, label: "Posts"),
                  TownsquareBarButton(icon: Icons.account_circle, label: "Profile"),

                  verticalSpacing(sectionSpacing),
                  Text("Friends", style: Theme.of(context).textTheme.titleLarge),
                  verticalSpacing(defaultSpacing * 0.5),
                  TownsquareBarButton(icon: Icons.account_circle, label: "Friend 1"),
                  verticalSpacing(sectionSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TownsquareBarButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const TownsquareBarButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: defaultSpacing),
      child: Material(
        color: Get.theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(defaultSpacing),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(defaultSpacing),
          child: Padding(
            padding: const EdgeInsets.all(defaultSpacing),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: Get.theme.textTheme.titleLarge!.fontSize! * 1.5),
                horizontalSpacing(defaultSpacing),
                Expanded(child: Text(label, style: Theme.of(context).textTheme.labelLarge!, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
