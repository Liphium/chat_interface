import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/login/login_step_page.dart';
import 'package:chat_interface/theme/components/fj_option_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginChoosePage extends StatefulWidget {

  final List<AuthType> options;

  const LoginChoosePage(this.options, {super.key});

  @override
  State<LoginChoosePage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginChoosePage> {

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
                child: Text("login.choose".tr, textAlign: TextAlign.start,
                    style: theme.textTheme.headlineMedium),
              ),
              verticalSpacing(defaultSpacing * 0.5),
              Column(
                children: List.generate(widget.options.length, (index) {
                  final type = widget.options[index];

                  return Padding(
                    padding: const EdgeInsets.only(top: defaultSpacing),
                    child: FJOptionButton(
                      text: "choose.${type.name}".tr,
                      onTap: () {
                        Get.offAll(const LoginStepPage(), transition: Transition.noTransition);
                      },
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
