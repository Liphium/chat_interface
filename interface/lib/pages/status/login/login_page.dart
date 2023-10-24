import 'package:chat_interface/pages/status/register/register_page.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  final _loading = false.obs;
  final _emailError = ''.obs;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: TransitionContainer(
          tag: "login",
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(defaultSpacing * 1.5),
            topRight: Radius.circular(defaultSpacing * 1.5),
            bottomLeft: Radius.circular(defaultSpacing * 1.5),
            bottomRight: Radius.circular(defaultSpacing * 1.5),
          ),
          color: theme.colorScheme.onBackground,
          width: 370,
          child: Padding(
            padding: const EdgeInsets.all(defaultSpacing * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${"input.email".tr}.", textAlign: TextAlign.start,
                    style: theme.textTheme.headlineMedium),
                verticalSpacing(defaultSpacing * 2),
                Obx(
                  () => FJTextField(
                    hintText: 'placeholder.email'.tr,
                    errorText: _emailError.value == '' ? null : _emailError.value,
                    controller: _emailController,
                  ),
                ),
                verticalSpacing(defaultSpacing * 1.5),
                FJElevatedButton(
                  onTap: () {
                    if (_loading.value) return;
                    _loading.value = true;
                
                    if (_emailController.text == '') {
                      _emailError.value = 'input.email'.tr;
                      _loading.value = false;
                      return;
                    }
                
                    _emailError.value = '';
                
                    loginStart(_emailController.text,
                        success: () async {
                          _loading.value = false;
                    }, failure: (msg) {
                      Get.snackbar("login.failed".tr, msg.tr);
                
                      switch (msg) {
                        case "invalid.email":
                          _emailError.value = msg.tr;
                          break;
                      }
                      _loading.value = false;
                    });
                  },
                  child: Center(
                    child: Obx(() => _loading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ))
                        : Text('login.next'.tr, style: theme.textTheme.labelLarge)),
                  ),
                ),
                verticalSpacing(defaultSpacing * 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("login.no_account.text".tr),
                    horizontalSpacing(defaultSpacing),
                    TextButton(
                      onPressed: () => Get.find<TransitionController>().modelTransition(const RegisterPage()),
                      child: Text('login.no_account'.tr),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
