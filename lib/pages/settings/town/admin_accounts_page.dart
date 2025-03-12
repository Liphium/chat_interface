import 'dart:async';
import 'dart:isolate';

import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/pages/settings/town/admin_account_profile.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/lph_page_switcher.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class AccountData {
  String id;
  String email;
  String username;
  String displayName;
  int rankID;
  DateTime createdAt;
  final deleted = signal(false);
  final deleteLoading = signal(false);

  AccountData({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    required this.rankID,
    required this.createdAt,
  });

  // Factory constructor to create Account object from JSON
  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      rankID: json['rank'] as int,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Method to convert Account object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'rank': rankID,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AdminAccountsPage extends StatefulWidget {
  const AdminAccountsPage({super.key});

  @override
  State<AdminAccountsPage> createState() => _AdminAccountsPageState();
}

class _AdminAccountsPageState extends State<AdminAccountsPage> {
  final _accounts = listSignal<AccountData>([]);
  final _query = signal("");
  final _startLoading = signal(true);
  final _pageLoading = signal(false);
  final _currentPage = signal(0);
  final _totalCount = signal(0);
  Future? _currentFuture;

  @override
  void dispose() {
    _accounts.dispose();
    _query.dispose();
    _startLoading.dispose();
    _pageLoading.dispose();
    _currentPage.dispose();
    _totalCount.dispose();
    super.dispose();
  }

  @override
  void initState() {
    goToPage(0);

    _query.subscribe(
      (qry) async {
        if (_currentFuture != null) {
          await _currentFuture;
        }
        unawaited(goToPage(_currentPage.value));
        _currentFuture = Future.delayed(500.ms);
      },
    );

    super.initState();
  }

  Future<void> goToPage(int page) async {
    // Set the current page
    if (_pageLoading.value) {
      return;
    }
    _pageLoading.value = true;
    _currentPage.value = page;

    // Get the files from the server
    final json = await postAuthorizedJSON("/townhall/accounts/list", {
      "page": page,
      "query": _query.value,
    });
    _startLoading.value = false;
    _pageLoading.value = false;

    // Check if there was an error
    if (!json["success"]) {
      showErrorPopup("error", json["error"]);
      return;
    }

    // Parse the entire json
    if (json["accounts"] == null) {
      _accounts.clear();
      return;
    }

    // Set the total amount of files
    _totalCount.value = json["count"];

    // Decrypt some stuff in an isolate
    final list = await Isolate.run(() {
      final list = <AccountData>[];

      for (var file in json["accounts"]) {
        list.add(AccountData.fromJson(file));
      }

      return list;
    });

    // Update the UI
    _accounts.value = list;
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "accounts",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: FJTextField(
              prefixIcon: Icons.search,
              hintText: "settings.accounts.search".tr,
              secondaryColor: true,
              onChange: (qry) {
                _query.value = qry;
              },
            ),
          ),
          verticalSpacing(defaultSpacing),
          Watch((ctx) {
            if (_startLoading.value) {
              return CircularProgressIndicator(
                color: Get.theme.colorScheme.onPrimary,
              );
            }

            if (!_accounts.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: elementSpacing),
                child: Text("settings.accounts.none".tr, style: Get.theme.textTheme.bodyMedium),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top page switcher element
                LPHPageSwitcher(
                  loading: _pageLoading,
                  currentPage: _currentPage,
                  count: _totalCount,
                  page: (page) => goToPage(page),
                ),
                verticalSpacing(defaultSpacing),

                // The view rendering all the accounts
                ListView.builder(
                  itemCount: _accounts.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final account = _accounts[index];

                    // Obx for delete animation
                    return Watch(
                      (ctx) => Animate(
                        key: ValueKey(account.id),
                        effects: [
                          ReverseExpandEffect(
                            axis: Axis.vertical,
                            curve: const ElasticOutCurve(2.0),
                            duration: 1000.ms,
                          ),
                          ScaleEffect(
                            begin: const Offset(1, 1),
                            end: const Offset(0, 0),
                            curve: Curves.ease,
                            duration: 1000.ms,
                          ),
                          FadeEffect(
                            begin: 1,
                            end: 0,
                            duration: 1000.ms,
                          )
                        ],
                        onInit: (controller) => controller.value = account.deleted.value ? 1 : 0,
                        target: account.deleted.value ? 1 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: defaultSpacing),
                          child: Material(
                            color: Get.theme.colorScheme.onInverseSurface,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.account_circle,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      size: 30,
                                    ),
                                    horizontalSpacing(defaultSpacing),

                                    // Account data (name and creation)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${account.displayName} (${account.username})", style: Get.theme.textTheme.labelMedium),
                                        Text(
                                          "settings.accounts.created".trParams({
                                            "date": formatOnlyYear(account.createdAt),
                                            "time": formatMessageTime(account.createdAt),
                                          }),
                                          style: Get.theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Actions that can be performed on the account
                                Row(
                                  children: [
                                    // Launch button (go to manage their account)
                                    LoadingIconButton(
                                      onTap: () => Get.dialog(AdminAccountProfile(account: account)),
                                      icon: Icons.launch,
                                    ),

                                    // Delete icon button
                                    LoadingIconButton(
                                      loading: account.deleteLoading,
                                      onTap: () async {
                                        if (account.deleteLoading.value) {
                                          return;
                                        }

                                        unawaited(showConfirmPopup(ConfirmWindow(
                                          title: "settings.accounts.delete.confirm".tr,
                                          text: "settings.accounts.delete.desc".tr,
                                          onConfirm: () async {
                                            account.deleteLoading.value = true;
                                            final json = await postAuthorizedJSON("/townhall/accounts/delete", {
                                              "account": account.id,
                                            });
                                            account.deleteLoading.value = false;

                                            if (!json["success"]) {
                                              showErrorPopup("error", json["error"]);
                                              return;
                                            }

                                            account.deleted.value = true;
                                          },
                                        )));
                                      },
                                      icon: Icons.delete,
                                    ),
                                  ],
                                )
                              ]),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Bottom page switcher
                LPHPageSwitcher(
                  loading: _pageLoading,
                  currentPage: _currentPage,
                  count: _totalCount,
                  page: (page) => goToPage(page),
                ),
                verticalSpacing(defaultSpacing),
              ],
            );
          })
        ],
      ),
    );
  }
}
