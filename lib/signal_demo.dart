import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class SignalDemo extends StatefulWidget {
  const SignalDemo({super.key});

  @override
  State<SignalDemo> createState() => _SignalDemoState();
}

class _SignalDemoState extends State<SignalDemo> with SignalsMixin {
  late final count = createSignal(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Current value: ${count.value}"),
              verticalSpacing(sectionSpacing),
              FJElevatedButton(onTap: () => count.value++, child: Text("Increment")),
            ],
          ),
        ),
      ),
    );
  }
}
