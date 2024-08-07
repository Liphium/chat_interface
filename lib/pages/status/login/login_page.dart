import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/pages/status/login/server_selector_container.dart';
import 'package:chat_interface/pages/status/register/register_handler.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_handler.dart';

class LoginPage extends StatefulWidget {
  final String? email;

  const LoginPage({super.key, this.email});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  final _loading = false.obs;
  final _errorText = ''.obs;
  bool reminded = false;
  final _reminderText = ''.obs;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _emailController.text = widget.email ?? "";

    return Scaffold(
      backgroundColor: theme.colorScheme.inverseSurface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TransitionContainer(
              tag: "login",
              borderRadius: BorderRadius.circular(defaultSpacing * 1.5),
              color: theme.colorScheme.onInverseSurface,
              width: 370,
              child: Padding(
                padding: const EdgeInsets.all(defaultSpacing * 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${"input.email".tr}.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    verticalSpacing(sectionSpacing),
                    AnimatedInfoContainer(
                      padding: const EdgeInsets.only(bottom: defaultSpacing),
                      message: _reminderText,
                      expand: true,
                    ),
                    FJTextField(
                      hintText: 'placeholder.email'.tr,
                      controller: _emailController,
                      maxLines: 1,
                    ),
                    verticalSpacing(defaultSpacing),
                    AnimatedErrorContainer(
                      padding: const EdgeInsets.only(bottom: defaultSpacing),
                      message: _errorText,
                      expand: true,
                    ),
                    FJElevatedLoadingButton(
                      loading: _loading,
                      onTap: () {
                        if (_loading.value) return;
                        _loading.value = true;
                        _errorText.value = ''.tr;
                        _reminderText.value = ''.tr;

                        if (_emailController.text == '') {
                          _errorText.value = 'email.invalid'.tr;
                          if (!reminded) {
                            _reminderText.value = 'login.register_reminder'.tr;
                          }
                          reminded = true;
                          _loading.value = false;
                          return;
                        }

                        loginStart(_emailController.text, success: () async {
                          _loading.value = false;
                        }, failure: (msg) {
                          _errorText.value = msg.tr;
                          _loading.value = false;
                        });
                      },
                      label: 'login.next'.tr,
                    ),
                    verticalSpacing(defaultSpacing),
                    Center(
                      child: TextButton(
                        style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(theme.colorScheme.onPrimary),
                          backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.hovered)
                              ? theme.colorScheme.primary.withOpacity(0.3)
                              : theme.colorScheme.primary.withOpacity(0)),
                        ),
                        onPressed: () => RegisterHandler.goToRegistration(_emailController.text),
                        child: Text('login.no_account'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            verticalSpacing(defaultSpacing),
            ServerSelectorContainer(pageToGoBack: () => LoginPage(email: _emailController.text)),
          ],
        ),
      ),
    );
  }
}
