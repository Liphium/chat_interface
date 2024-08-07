import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/pages/status/login/login_page.dart';
import 'package:chat_interface/pages/status/login/server_selector_container.dart';
import 'package:chat_interface/pages/status/register/register_code_page.dart';
import 'package:chat_interface/pages/status/register/register_handler.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterStartPage extends StatefulWidget {
  final String? email;

  const RegisterStartPage({super.key, this.email});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "register.title".tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
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
                    FJElevatedLoadingButton(
                      loading: _loading,
                      onTap: () async {
                        if (_loading.value) return;
                        _loading.value = true;
                        _errorText.value = "";

                        // Check all the stuff
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

                        // Send registration start request
                        final error = await RegisterHandler.startRegister(_loading, _emailController.text.trim(), _inviteController.text.trim());
                        if (error != null) {
                          _errorText.value = error.tr;
                          return;
                        }

                        // Transition to the next page
                        Get.find<TransitionController>().modelTransition(const RegisterCodePage());
                      },
                      label: 'login.next'.tr,
                    ),
                    verticalSpacing(defaultSpacing),
                    Center(
                      child: TextButton(
                        style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(theme.colorScheme.onPrimary),
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.hovered) ? theme.colorScheme.primary.withOpacity(0.3) : theme.colorScheme.primary.withOpacity(0)),
                        ),
                        onPressed: () => Get.find<TransitionController>().modelTransition(LoginPage(email: _emailController.text)),
                        child: Text('register.login'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            verticalSpacing(defaultSpacing),
            ServerSelectorContainer(pageToGoBack: () => RegisterStartPage(email: _emailController.text)),
          ],
        ),
      ),
    );
  }
}
