import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/register/register_code_page.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterStartPage extends StatefulWidget {
  const RegisterStartPage({super.key});

  @override
  State<RegisterStartPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterStartPage> {
  final _inviteController = TextEditingController();
  final _emailController = TextEditingController();

  final _loading = false.obs;
  final _errorText = "".obs;

  @override
  void dispose() {
    _inviteController.dispose();
    _emailController.dispose();
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
                Text("register.title".tr, textAlign: TextAlign.left, style: theme.textTheme.headlineMedium),
                verticalSpacing(sectionSpacing),

                // Invite
                Tooltip(
                  message: "invite.info".tr,
                  child: Text("invite".tr, textAlign: TextAlign.left, style: theme.textTheme.labelLarge),
                ),
                verticalSpacing(elementSpacing),
                FJTextField(
                  hintText: 'placeholder.invite'.tr,
                  controller: _inviteController,
                ),
                verticalSpacing(defaultSpacing),

                // Email
                Text("email".tr, textAlign: TextAlign.left, style: theme.textTheme.labelLarge),
                verticalSpacing(elementSpacing),
                FJTextField(
                  hintText: 'placeholder.email'.tr,
                  controller: _emailController,
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

                    if (_inviteController.text == '') {
                      _errorText.value = 'invite.invalid'.tr;
                      _loading.value = false;
                      return;
                    }

                    if (_emailController.text == '') {
                      _errorText.value = 'email.invalid'.tr;
                      _loading.value = false;
                      return;
                    }

                    sendLog("register and stuff");
                    Get.find<TransitionController>().modelTransition(const RegisterCodePage());
                  },
                  loading: _loading,
                  child: Center(
                    child: Text('login.next'.tr, style: theme.textTheme.labelLarge),
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
