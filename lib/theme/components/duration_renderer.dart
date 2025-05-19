import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:signals/signals_flutter.dart';

class DurationRenderer extends StatefulWidget {
  final DateTime start;
  final TextStyle? style;

  const DurationRenderer(this.start, {this.style, super.key});

  @override
  State<DurationRenderer> createState() => _DurationRendererState();
}

class _DurationRendererState extends State<DurationRenderer> with SignalsMixin {
  late final _current = createSignal(const Duration(seconds: 0));

  @override
  Widget build(BuildContext context) {
    _current.value = DateTime.now().difference(widget.start);
    Timer.periodic(const Duration(seconds: 1), (timer) => _current.value = DateTime.now().difference(widget.start));

    final duration = _current.value;
    final hours = duration.inHours;
    final minutes = duration.inMinutes - (hours * 60);
    final seconds = duration.inSeconds - (minutes * 60) - (hours * 60 * 60);

    if (hours > 0) {
      return Text(
        "${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}",
        style: widget.style,
      );
    }
    return Text("${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}", style: widget.style);
  }
}
