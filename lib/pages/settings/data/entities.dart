import 'dart:convert';

import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/settings/account/authentication_settings.dart';
import 'package:chat_interface/pages/settings/account/data_settings.dart';
import 'package:chat_interface/pages/settings/account/invites_page.dart';
import 'package:chat_interface/pages/settings/town/admin_accounts_page.dart';
import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:chat_interface/pages/settings/app/language_settings.dart';
import 'package:chat_interface/pages/settings/app/log_settings.dart';
import 'package:chat_interface/pages/settings/town/spaces_settings.dart';
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/town/tabletop_settings.dart';
import 'package:chat_interface/pages/settings/app/video_settings.dart';
import 'package:chat_interface/pages/settings/appearance/chat_settings.dart';
import 'package:chat_interface/pages/settings/appearance/theme_settings.dart';
import 'package:chat_interface/pages/settings/security/trusted_links_settings.dart';
import 'package:chat_interface/pages/settings/town/town_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SettingLabel {
  // Account settings (everything to do with the account and stored on the server)
  account("settings.tab.account", [
    SettingCategory("data", Icons.account_circle, DataSettingsPage()),
    SettingCategory("invites", Icons.mail, InvitesPage(), displayTitle: false),
    //SettingCategory("profile", Icons.assignment, null),
    //SettingCategory("authentication", Icons.security, AuthenticationSettingsPage()),
    //SettingCategory("devices", Icons.phone_android, null),
  ]),

  // Everything related to the town and its features
  town("settings.tab.town", [
    SettingCategory("town", Icons.cottage, TownSettingsPage()),
    SettingCategory("accounts", Icons.person_search, AdminAccountsPage(), admin: true),
    SettingCategory("tabletop", Icons.table_restaurant, TabletopSettingsPage(), mobile: false, web: false),
    SettingCategory("spaces", Icons.rocket_launch, SpacesSettingsPage(), mobile: false, web: false),
    SettingCategory("files", Icons.folder, FileSettingsPage()),
  ]),

  // Everything to do with the app (that's stored locally)
  app("settings.tab.app", [
    SettingCategory("general", Icons.dashboard, LanguageSettingsPage()),
    SettingCategory("audio", Icons.campaign, AudioSettingsPage(), mobile: false, web: false),
    SettingCategory("camera", Icons.videocam, VideoSettingsPage(), mobile: false, web: false),
    //SettingCategory("notifications", Icons.notifications, null),
    SettingCategory("logging", Icons.insights, LogSettingsPage()),
  ]),

  // Everything to do with the appereance of the app
  appearance("settings.tab.appearance", [
    SettingCategory("chat", Icons.chat_bubble, ChatSettingsPage()),
    SettingCategory("colors", Icons.color_lens, ThemeSettingsPage(), mobile: false, web: false),
    //SettingCategory("call_app", Icons.cable, CallSettingsPage()),
  ]),

  privacy("settings.tab.security", [
    SettingCategory("trusted_links", Icons.link, TrustedLinkSettingsPage()),
  ]);

  final String _label;
  final List<SettingCategory> categories;

  const SettingLabel(this._label, this.categories);

  String get label => _label;
  String get translated => _label.tr;
}

class SettingCategory {
  final String label;
  final IconData icon;
  final Widget? widget;
  final bool mobile;
  final bool admin;
  final bool displayTitle;
  final bool web;

  const SettingCategory(this.label, this.icon, this.widget, {this.displayTitle = true, this.mobile = true, this.admin = false, this.web = true});
}

class Setting<T> {
  final String label;
  final Rx<T?> value = Rx<T?>(null);
  T defaultValue;

  Setting(this.label, this.defaultValue);

  String get translated => label.tr;

  void grabFrom(String s) {
    this.value.value = jsonDecode(s)["v"] as T;
  }

  Future<bool> grabFromDb() async {
    final val = await (db.select(db.setting)..where((tbl) => tbl.key.equals(label))).getSingleOrNull();
    grabFrom((val ?? SettingData(key: label, value: stringify())).value);
    return true;
  }

  String stringify() {
    return jsonEncode({"v": getValue()});
  }

  void setValue(T value) async {
    this.value.value = value;
    await db.into(db.setting).insertOnConflictUpdate(SettingData(key: label, value: stringify()));
  }

  T getValue() => value.value == null ? defaultValue : value.value!;
  T? getOrNull() => value.value;

  T getOr(T other) => value.value ?? other;
  T getWhenValue(T other, T def) => value.value == other ? def : value.value ?? defaultValue;
}
