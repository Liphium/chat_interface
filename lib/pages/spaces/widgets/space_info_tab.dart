import 'package:chat_interface/pages/spaces/widgets/space_grid_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

class SpaceInfoTab extends StatefulWidget {
  const SpaceInfoTab({super.key});

  @override
  State<SpaceInfoTab> createState() => _SpaceInfoTabState();
}

class _SpaceInfoTabState extends State<SpaceInfoTab> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpaceGridRenderer(
        amount: 1,
        padding: sectionSpacing,
        renderer: (index) {
          return Placeholder();
        },
      ),
    );
  }
}
