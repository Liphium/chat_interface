import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/register/register_handler.dart';
import 'package:chat_interface/standards/unicode_string.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterFinishPage extends StatefulWidget {
  const RegisterFinishPage({super.key});

  @override
  State<RegisterFinishPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterFinishPage> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _loading = false.obs;
  final _errorText = "".obs;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.inverseSurface,
      body: Center(
        child: TransitionContainer(
          tag: "login",
          borderRadius: BorderRadius.circular(defaultSpacing * 1.5),
          color: theme.colorScheme.onInverseSurface,
          width: 370,
          child: Padding(
            padding: const EdgeInsets.all(defaultSpacing * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("register.final".tr, textAlign: TextAlign.left, style: theme.textTheme.headlineMedium),
                verticalSpacing(sectionSpacing),

                Text("username".tr, textAlign: TextAlign.left, style: theme.textTheme.labelLarge),
                verticalSpacing(elementSpacing),
                Text("username.description".tr, textAlign: TextAlign.left, style: theme.textTheme.bodyMedium),
                verticalSpacing(elementSpacing),
                FJTextField(
                  hintText: 'placeholder.username'.tr,
                  controller: _usernameController,
                  maxLength: 16,
                ),
                verticalSpacing(defaultSpacing),

                Text("display_name".tr, textAlign: TextAlign.left, style: theme.textTheme.labelLarge),
                verticalSpacing(elementSpacing),
                Text("display_name.description".tr, textAlign: TextAlign.left, style: theme.textTheme.bodyMedium),
                verticalSpacing(elementSpacing),
                FJTextField(
                  hintText: 'placeholder.display_name'.tr,
                  controller: _displayNameController,
                  maxLength: 20,
                ),
                verticalSpacing(defaultSpacing),

                // Password
                Text("password".tr, textAlign: TextAlign.left, style: theme.textTheme.labelLarge),
                verticalSpacing(elementSpacing),
                FJTextField(
                  hintText: 'placeholder.password'.tr,
                  obscureText: true,
                  controller: _passwordController,
                ),
                verticalSpacing(defaultSpacing),
                FJTextField(
                  hintText: 'placeholder.password'.tr,
                  obscureText: true,
                  controller: _confirmPasswordController,
                ),
                verticalSpacing(defaultSpacing),
                AnimatedErrorContainer(
                  padding: const EdgeInsets.only(bottom: defaultSpacing),
                  message: _errorText,
                  expand: true,
                ),
                FJElevatedLoadingButtonCustom(
                  onTap: () async {
                    if (_loading.value) return;
                    _loading.value = true;
                    _errorText.value = "";

                    // Check all the stuff
                    if (_usernameController.text == '' || _usernameController.text.length < 3) {
                      _errorText.value = 'username.invalid'.tr;
                      _loading.value = false;
                      return;
                    }

                    // Check all the stuff
                    if (_displayNameController.text == '' || _displayNameController.text.length < 3) {
                      _errorText.value = 'display_name.invalid'.tr;
                      _loading.value = false;
                      return;
                    }

                    if (_passwordController.text.length < 8) {
                      _errorText.value = 'password.invalid'.tr;
                      _loading.value = false;
                      return;
                    }

                    if (_passwordController.text != _confirmPasswordController.text) {
                      _errorText.value = 'password.mismatch'.tr;
                      _loading.value = false;
                      return;
                    }

                    // Send registration finish request
                    final error = await RegisterHandler.finishRegistration(
                        _loading, _usernameController.text, UTFString(_displayNameController.text).transform(), _passwordController.text);
                    if (error != null) {
                      _errorText.value = error;
                      return;
                    }

                    // Transition to the next page
                    Get.find<TransitionController>().modelTransition(const LoginPage());
                    sendLog("registration finished");
                  },
                  loading: _loading,
                  child: Center(
                    child: Text('register.register'.tr, style: theme.textTheme.labelLarge),
                  ),
                ),
                verticalSpacing(defaultSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('register.account.text'.tr),
                    horizontalSpacing(defaultSpacing),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(theme.colorScheme.onPrimary),
                        backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.hovered)
                            ? theme.colorScheme.primary.withOpacity(0.3)
                            : theme.colorScheme.primary.withOpacity(0)),
                      ),
                      onPressed: () => Get.find<TransitionController>().modelTransition(const LoginPage()),
                      child: Text('register.login'.tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
