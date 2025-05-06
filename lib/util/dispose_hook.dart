import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class DisposeHook extends StatefulWidget {
  final Function() dispose;
  final Widget child;

  const DisposeHook({super.key, required this.dispose, required this.child});

  @override
  State<DisposeHook> createState() => _DisposeHookState();
}

class _DisposeHookState extends State<DisposeHook> {
  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Create a Signal of type T that will be disposed automatically.
class SignalHook<T> extends StatefulWidget {
  final T value;
  final Widget Function(Signal<T>) builder;

  const SignalHook({super.key, required this.value, required this.builder});

  @override
  State<SignalHook<T>> createState() => _SignalHookState<T>();
}

class _SignalHookState<T> extends State<SignalHook<T>> with SignalsMixin {
  late final signal = createSignal<T>(widget.value);

  @override
  Widget build(BuildContext context) {
    return widget.builder(signal);
  }
}
