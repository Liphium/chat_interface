
import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'requests_actions.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final loading = false.obs;
  final TextEditingController _controller = TextEditingController();
  final value = ''.obs;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RequestController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        //* Add friend bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
          child: Material(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(defaultSpacing * 1.5),
              topRight: Radius.circular(defaultSpacing * 1.5),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
        
                  //* Text field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person,
                            color: theme.colorScheme.primary),
                        hintText: 'requests.placeholder'.tr,
                      ),
                    ),
                  ),
        
                  //* Add friend button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                    child: LoadingIconButton(
                      color: theme.colorScheme.primary,
                      onTap: () => _addButton(_controller.text, loading, success: (str) => _controller.clear()),
                      loading: loading,
                      icon: Icons.person_add,
                    ),
                  )
                ]),
          ),
        ),

        //* Requests list
        Expanded(
          child: Obx(() => controller.requests.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(defaultSpacing),
                  addRepaintBoundaries: true,
                  itemCount: controller.requests.length,
                  itemBuilder: (context, index) {
                    Request request = controller.requests[index];

                    //* Request item
                    return Padding(
                        padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            hoverColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withAlpha(100),
                            splashColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withAlpha(100),
                            onTap: () {},

                            //* Request item content
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: defaultSpacing,
                                  vertical: defaultSpacing * 0.5),
                              child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                          Row(
                                            children: [
                                              Icon(Icons.person,
                                                  size: 30,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                              const SizedBox(width: 10),
                                              Text(
                                                  "${request.name}#${request.tag}",
                                                  style: theme
                                                      .textTheme.titleMedium),
                                            ],
                                          ),

                                          //* Request actions
                                          Obx(() => request.loading.value ?

                                          const SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: Padding(
                                              padding: EdgeInsets.all(defaultSpacing * 0.25),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                              ),
                                            ),
                                          ) : 

                                          //* Accept/decline
                                          Row(
                                            children: [

                                              //* Accept request
                                              IconButton(
                                                icon: Icon(Icons.check,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                                onPressed: () => _addButton("${request.name}#${request.tag}", request.loading,),
                                              ),
                                              horizontalSpacing(defaultSpacing * 0.5),

                                              //* Decline request
                                              IconButton(
                                                icon: Icon(Icons.close,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                                onPressed: () {},
                                              ),
                                            ],
                                          )),
                                        ])),
                            ),
                          ),
                        );
                  },
                )
                
                //* Empty list
              : Center(
                  child: Text('requests.empty'.tr,
                      style: theme.textTheme.titleMedium))),
        ),
      ],
    );
  }
}
