import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
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
  final _tagController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _loading = false.obs;
  final _errorText = "".obs;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: TransitionContainer(
          tag: "login",
          borderRadius: BorderRadius.circular(defaultSpacing * 1.5),
          color: theme.colorScheme.onBackground,
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
                LayoutBuilder(builder: (context, size) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: size.maxWidth * 0.6,
                        child: FJTextField(
                          hintText: 'placeholder.username'.tr,
                          controller: _usernameController,
                          maxLength: 16,
                        ),
                      ),
                      Text('#', style: theme.textTheme.headlineMedium),
                      SizedBox(
                        width: size.maxWidth * 0.3,
                        child: FJTextField(
                          hintText: 'placeholder.tag'.tr,
                          controller: _tagController,
                          maxLength: 5,
                        ),
                      ),
                    ],
                  );
                }),
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
                  onTap: () {
                    if (_loading.value) return;
                    _loading.value = true;
                    _errorText.value = "";

                    if (_usernameController.text == '') {
                      _errorText.value = 'username.invalid'.tr;
                      _loading.value = false;
                      return;
                    }

                    if (_tagController.text == '') {
                      _errorText.value = 'tag.invalid'.tr;
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
                        foregroundColor: MaterialStateProperty.all(theme.colorScheme.onPrimary),
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => states.contains(MaterialState.hovered) ? theme.colorScheme.primary.withOpacity(0.3) : theme.colorScheme.primary.withOpacity(0)),
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
