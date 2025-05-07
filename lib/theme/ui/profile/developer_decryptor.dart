import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class DeveloperDecryptor extends StatefulWidget {
  const DeveloperDecryptor({super.key});

  @override
  State<DeveloperDecryptor> createState() => _DeveloperDecryptorState();
}

class _DeveloperDecryptorState extends State<DeveloperDecryptor> with SignalsMixin {
  late final _vaultResult = createSignal("");

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        children: [
          FJTextField(
            hintText: "to decrypt",
            onChange: (value) {
              // Try decryption
              try {
                _vaultResult.value = decryptSymmetric(value, vaultKey);
              } catch (_) {}
            },
          ),
          verticalSpacing(defaultSpacing),
          Text("Result: ${_vaultResult.value}"),
        ],
      ),
    );
  }
}
