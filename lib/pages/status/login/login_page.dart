import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/register/register_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
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
  final _passwordController = TextEditingController();

  final _loading = false.obs;
  final _passwordError = ''.obs;
  final _emailError = ''.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(defaultSpacing * 1.5),
              topRight: Radius.circular(defaultSpacing * 1.5),
              bottomLeft: Radius.circular(defaultSpacing * 1.5),
              bottomRight: Radius.circular(defaultSpacing * 1.5),
            ),
            color: theme.colorScheme.onBackground,
          ),
          padding: const EdgeInsets.all(defaultSpacing * 2),
          width: 370,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: "title",
                child: Text("login.title".tr, textAlign: TextAlign.start,
                    style: theme.textTheme.headlineMedium),
              ),
              verticalSpacing(defaultSpacing * 2),
              Obx(
                () => FJTextField(
                  hintText: 'placeholder.email'.tr,
                  errorText: _emailError.value == '' ? null : _emailError.value,
                  controller: _emailController,
                ),
              ),
              verticalSpacing(defaultSpacing),
              Obx(
                () => FJTextField(
                  hintText: 'placeholder.password'.tr,
                  obscureText: true,
                  errorText: _passwordError.value == '' ? null : _passwordError.value,
                  controller: _passwordController,
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
              
                  if (_passwordController.text == '') {
                    _passwordError.value = 'input.password'.tr;
                    _loading.value = false;
                    return;
                  }
              
                  _passwordError.value = '';
                  _emailError.value = '';
              
                  login(_emailController.text, _passwordController.text,
                      success: () async {
                    await db.into(db.setting).insertOnConflictUpdate(
                        SettingData(
                            key: "profile", value: tokensToPayload()));
                    setupManager.next();
                  }, failure: (msg) {
                    Get.snackbar("login.failed".tr, msg.tr);
              
                    switch (msg) {
                      case "invalid.password":
                        _passwordError.value = msg.tr;
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
                      : Text('login.login'.tr, style: theme.textTheme.labelLarge)),
                ),
              ),
              verticalSpacing(defaultSpacing * 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('login.forgot.text'.tr),
                  horizontalSpacing(defaultSpacing),
                  TextButton(
                    onPressed: () => setupManager.restart(),
                    child: Text('login.forgot'.tr),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('login.no_account.text'.tr),
                  horizontalSpacing(defaultSpacing),
                  TextButton(
                    onPressed: () => Get.offAll(const RegisterPage(), transition: Transition.noTransition),
                    child: Text('login.no_account'.tr),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
