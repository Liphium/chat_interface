import 'package:chat_interface/pages/initialization/initialization_page.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

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
              Text("login.page".tr),
              verticalSpacing(defaultSpacing),
              TextField(
                decoration: InputDecoration(
                  hintText: 'input.username'.tr,
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'input.password'.tr,
                ),
              ),
              verticalSpacing(defaultSpacing * 1.5),
              ElevatedButton(
                onPressed: () => Get.off(const InitializationPage(), transition: Transition.fadeIn),
                child: Text('login.button'.tr),
              ),
              verticalSpacing(defaultSpacing * 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('login.forgot.text'.tr),
                  horizontalSpacing(defaultSpacing),
                  TextButton(
                    onPressed: () => Get.off(const InitializationPage(), transition: Transition.fadeIn),
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
                    onPressed: () => Get.off(const InitializationPage(), transition: Transition.fadeIn),
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