import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/register/register_handler.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _loading = false.obs;
  final _passwordError = ''.obs;
  final _emailError = ''.obs;
  final _usernameError = ''.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("register.page".tr),
              verticalSpacing(defaultSpacing),
              Obx(() =>
                TextField(
                  decoration: InputDecoration(
                    hintText: 'input.username_tag'.tr,
                    errorText: _usernameError.value == '' ? null : _usernameError.value,
                  ),
                  controller: _usernameController,
                ),
              ),
              Obx(() =>
                TextField(
                  decoration: InputDecoration(
                    hintText: 'input.email'.tr,
                    errorText: _emailError.value == '' ? null : _emailError.value,
                  ),
                  controller: _emailController,
                ),
              ),
              Obx(() =>
                TextField(
                  decoration: InputDecoration(
                    hintText: 'input.password'.tr,
                    errorText: _passwordError.value == '' ? null : _passwordError.value,
                  ),
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  controller: _passwordController,
                ),
              ),
              verticalSpacing(defaultSpacing * 1.5),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
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
                      _usernameError.value = 'input.username_tag'.tr;
                      _loading.value = false;
                      return;
                    }
                
                    _passwordError.value = '';
                    _emailError.value = '';
                
                    register(_emailController.text, _usernameController.text, _passwordController.text,
                      success: () async {
                        Get.offAll(const LoginPage(), transition: Transition.fade);
                        _loading.value = false;
                      },
                      failure: (msg) {
                        Get.snackbar("register.failed".tr, msg.tr);
                        _loading.value = false;
                      });
                  },
                  child: Obx(() => _loading.value ? 
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    )
                  ) : 
                  Text('login.login'.tr)),
                )
              ),
              verticalSpacing(defaultSpacing * 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('register.account.text'.tr),
                  horizontalSpacing(defaultSpacing),
                  TextButton(
                    onPressed: () => Get.offAll(const LoginPage(), transition: Transition.fade),
                    child: Text('register.login'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}