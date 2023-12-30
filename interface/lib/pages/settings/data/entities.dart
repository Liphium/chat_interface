import 'dart:convert';

import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/settings/account/data_settings.dart';
import 'package:chat_interface/pages/settings/account/invites_page.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/app/language_settings.dart';
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/appearance/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SettingLabel {

  // Account settings (everything to do with the account and stored on the server)
  account("settings.tab.account", [
    SettingCategory("data", Icons.account_circle, DataSettingsPage()),
    SettingCategory("invites", Icons.mail, InvitesPage(), displayTitle: false)
    //SettingCategory("profile", Icons.assignment, null),
    //SettingCategory("security", Icons.security, null),
    //SettingCategory("devices", Icons.phone_android, null),
  ]),

  // Everything to do with the app (that's stored locally)
  app("settings.tab.app", [
    //SettingCategory("spaces", Icons.rocket_launch, SpacesSettingsPage()),
    SettingCategory("files", Icons.folder, FileSettingsPage()),
    SettingCategory("audio", Icons.campaign, AudioSettingsPage()),
    //SettingCategory("notifications", Icons.notifications, null),
    SettingCategory("language", Icons.public, LanguageSettingsPage()),
  ]),

  // Everything to do with the appereance of the app
  appearance("settings.tab.appearance", [
    SettingCategory("colors", Icons.color_lens, ThemeSettingsPage()),
    //SettingCategory("call_app", Icons.cable, CallSettingsPage()),
  
  ])
  
  /* Commented out for now
  privacy("settings.tab.privacy", [
    //SettingCategory("requests", Icons.group, null),
    //SettingCategory("encryption", Icons.key, null),
  ])
  */

  ;

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
  final bool displayTitle;

  const SettingCategory(this.label, this.icon, this.widget, {this.displayTitle = true});
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

  T getOr(T other) => value.value ?? other;
  T getWhenValue(T other, T def) => value.value == other ? def : value.value ?? defaultValue;

}