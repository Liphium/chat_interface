import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/register/register_finish_page.dart';
import 'package:chat_interface/pages/status/register/register_handler.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterCodePage extends StatefulWidget {
  const RegisterCodePage({super.key});

  @override
  State<RegisterCodePage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterCodePage> {
  final _inviteController = TextEditingController();

  final _loading = false.obs;
  final _errorText = "".obs;

  @override
  void dispose() {
    _inviteController.dispose();
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
                Text("register.verify".tr,
                    textAlign: TextAlign.left,
                    style: theme.textTheme.headlineMedium),
                verticalSpacing(defaultSpacing),
                Text(
                  "register.email_validation".trParams({
                    "email": "test@gmail.com",
                  }),
                  textAlign: TextAlign.left,
                  style: theme.textTheme.bodyMedium,
                ),
                verticalSpacing(sectionSpacing),

                // Email code
                Text("code".tr,
                    textAlign: TextAlign.left,
                    style: theme.textTheme.labelLarge),
                verticalSpacing(elementSpacing),
                FJTextField(
                  hintText: 'placeholder.code'.tr,
                  controller: _inviteController,
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

                    // Check if the code is valid
                    if (_inviteController.text == '') {
                      _errorText.value = 'code.invalid'.tr;
                      _loading.value = false;
                      return;
                    }

                    // Verify the code
                    final error = await RegisterHandler.verifyCode(
                        _loading, _inviteController.text);
                    if (error != null) {
                      _errorText.value = error;
                      return;
                    }

                    // Go to the next page
                    Get.find<TransitionController>()
                        .modelTransition(const RegisterFinishPage());
                  },
                  loading: _loading,
                  child: Center(
                    child: Text('login.next'.tr,
                        style: theme.textTheme.labelLarge),
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
                        foregroundColor: MaterialStateProperty.all(
                            theme.colorScheme.onPrimary),
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => states.contains(MaterialState.hovered)
                                ? theme.colorScheme.primary.withOpacity(0.3)
                                : theme.colorScheme.primary.withOpacity(0)),
                      ),
                      onPressed: () => Get.find<TransitionController>()
                          .modelTransition(const LoginPage()),
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
