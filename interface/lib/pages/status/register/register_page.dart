import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/register/register_handler.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _usernameController = TextEditingController();
  final _tagController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _loading = false.obs;
  final _passwordError = ''.obs;
  final _emailError = ''.obs;
  final _usernameError = ''.obs;
  final _tagError = ''.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
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
                Text("register.title".tr, textAlign: TextAlign.left,
                    style: theme.textTheme.headlineMedium),
                verticalSpacing(defaultSpacing * 2),
                LayoutBuilder(
                  builder: (context, size) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() =>
                          SizedBox(
                            width: size.maxWidth * 0.6,
                            child: FJTextField(
                              hintText: 'placeholder.username'.tr,
                              errorText: _usernameError.value == '' ? null : _usernameError.value,
                              controller: _usernameController,
                            ),
                          ),
                        ),
                        Text('#', style: theme.textTheme.headlineMedium),
                        Obx(() =>
                          SizedBox(
                            width: size.maxWidth * 0.3,
                            child: FJTextField(
                              hintText: 'placeholder.tag'.tr,
                              errorText: _tagError.value == '' ? null : _tagError.value,
                              controller: _tagController,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                ),
                verticalSpacing(defaultSpacing),
                Obx(() =>
                  FJTextField(
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
                    if(_loading.value) return;
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
                
                    if (_usernameController.text == '') {
                      _usernameError.value = 'input.username'.tr;
                      _loading.value = false;
                      return;
                    }
          
                    if (_tagController.text == '') {
                      _tagError.value = 'input.tag'.tr;
                      _loading.value = false;
                      return;
                    }
                
                    _passwordError.value = '';
                    _emailError.value = '';
                
                    register(_emailController.text, _usernameController.text, _tagController.text, _passwordController.text,
                      success: () {
                        Get.find<TransitionController>().modelTransition(const LoginPage());
                        _loading.value = false;
                      },
                      failure: (msg) {
                        _loading.value = false;
          
                        switch (msg) {
                          case 'email.invalid':
                            _emailError.value = 'input.email'.tr;
                            return;
                        }
          
                        Get.snackbar("register.failed".tr, msg.tr);
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
                        : Text('register.register'.tr, style: theme.textTheme.labelLarge)
                    ),
                  ),
                ),
                verticalSpacing(defaultSpacing * 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('register.account.text'.tr),
                    horizontalSpacing(defaultSpacing),
                    TextButton(
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