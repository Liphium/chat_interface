import 'package:chat_interface/pages/status/login/login_choose_page.dart';
import 'package:chat_interface/pages/status/register/register_page.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/transitions/transition_container.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_interface/main.dart';

import 'login_handler.dart';

class LoginStepPage extends StatefulWidget {

  final List<AuthType>? options;
  final AuthType type;
  final String token;

  const LoginStepPage(this.type, this.token, {super.key, this.options});

  @override
  State<LoginStepPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginStepPage> {
  final _secretController = TextEditingController();

  final _loading = false.obs;
  final _secretError = ''.obs;

  @override
  void dispose() {
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: SizedBox(
          width: 370,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                maintainSize: false,
                maintainAnimation: false,
                visible: widget.options != null,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: defaultSpacing * 2),
                  child: FJElevatedButton(
                    onTap: () {
                      Get.find<TransitionController>().modelTransition(LoginChoosePage(widget.options!, widget.token));
                    },
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back),
                          horizontalSpacing(defaultSpacing),
                          Text('back'.tr, style: theme.textTheme.labelLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              TransitionContainer(
                tag: "login",
                borderRadius: BorderRadius.circular(defaultSpacing * 1.5),
                color: theme.colorScheme.onBackground,
                child: Padding(
                  padding: const EdgeInsets.all(defaultSpacing * 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${"input.${widget.type.name}".tr}.", textAlign: TextAlign.start,
                          style: theme.textTheme.headlineMedium),
                      verticalSpacing(defaultSpacing * 2),
                      Obx(
                        () => FJTextField(
                          obscureText: true,
                          hintText: 'placeholder.${widget.type.name}'.tr,
                          errorText: _secretError.value == '' ? null : _secretError.value,
                          controller: _secretController,
                        ),
                      ),
                      verticalSpacing(defaultSpacing * 1.5),
                      FJElevatedButton(
                        onTap: () {
                          
                          if(_secretController.text.isEmpty) {
                            _secretError.value = 'input.${widget.type.name}'.tr;
                            return;
                          }
                        
                          _loading.value = true;
                          _secretError.value = '';
                
                          loginStep(widget.token, _secretController.text, widget.type, 
                          success: () {
                            _loading.value = false;
                          },
                          failure: (err) {
                            _loading.value = false;
                            _secretError.value = err;
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
                              : Text('login.next'.tr, style: theme.textTheme.labelLarge)),
                        ),
                      ),
                      verticalSpacing(defaultSpacing * 1.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("login.forgot.text".tr),
                          horizontalSpacing(defaultSpacing),
                          TextButton(
                            onPressed: () => Get.offAll(const RegisterPage(), transition: Transition.noTransition),
                            child: Text('login.forgot'.tr),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
