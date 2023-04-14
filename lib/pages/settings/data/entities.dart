import 'dart:convert';

import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/settings/app/call/call_settings.dart';
import 'package:chat_interface/pages/settings/app/speech/speech_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SettingLabel {
  account("settings.tab.account", [
    SettingCategory("data", Icons.account_circle, null),
    SettingCategory("security", Icons.security, null),
    SettingCategory("devices", Icons.phone_android, null),
  ]),

  app("settings.tab.app", [
    SettingCategory("video", Icons.photo_camera, null),
    SettingCategory("audio", Icons.campaign, AudioSettingsPage()),
    SettingCategory("notifications", Icons.notifications, null),
  ]),

  appearance("settings.tab.appearance", [
    SettingCategory("theme", Icons.dark_mode, null),
    SettingCategory("call_app", Icons.cable, CallSettingsPage()),
    SettingCategory("language", Icons.public, null),
  ]),

  privacy("settings.tab.privacy", [
    SettingCategory("requests", Icons.group, null),
    SettingCategory("encryption", Icons.key, null),
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

  const SettingCategory(this.label, this.icon, this.widget);
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

  void grabFromDb() async {
    final val = await (db.select(db.setting)..where((tbl) => tbl.key.equals(label))).getSingleOrNull();
    grabFrom((val ?? SettingData(key: label, value: stringify())).value);
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