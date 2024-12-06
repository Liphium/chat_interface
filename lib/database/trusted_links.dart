import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/security/trusted_links_settings.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

class TrustedLink extends Table {
  TextColumn get domain => text()();

  @override
  Set<Column<Object>>? get primaryKey => {domain};
}

class TrustedLinkHelper {
  static late Setting _trustModeSetting;
  static late Setting _unsafeSetting;

  static void init() {
    final controller = Get.find<SettingController>();
    _unsafeSetting = controller.settings[TrustedLinkSettings.unsafeSources]!;
    _trustModeSetting = controller.settings[TrustedLinkSettings.trustMode]!;
  }

  /// Show a confirm popup to confirm the user wants to add a new domain (returns whether the domain was trusted)
  static Future<bool> askToAdd(String url) async {
    // Exclude own instance
    final domain = extractDomain(url);
    sendLog("$domain ${extractDomain(basePath)}");
    if (domain == extractDomain(basePath)) {
      return true;
    }

    if (url.startsWith("http://") && !_unsafeSetting.getValue()) {
      return false;
    }
    if (_trustModeSetting.getValue() == 2) {
      return false;
    }

    final result = await showConfirmPopup(ConfirmWindow(
      title: "file.links.title".tr,
      text: "file.links.description".trParams({
        "domain": domain,
      }),
    ));

    if (result) {
      await db.trustedLink.insertOnConflictUpdate(TrustedLinkData(domain: domain));
    }

    return result;
  }

  /// Ask for addition when the link is not trusted (returns whether trusted or not)
  static Future<bool> askToAddIfNotAdded(String url) async {
    if (await isLinkTrusted(url)) {
      return true;
    }

    // Ask to add
    return await askToAdd(url);
  }

  /// Returns wether it was added
  static Future<bool> addToTrustedLinks(String domain) async {
    if (await isLinkTrusted(domain)) {
      return false;
    }
    await db.trustedLink.insertOnConflictUpdate(TrustedLinkData(domain: domain));
    return true;
  }

  static Future<bool> isLinkTrusted(String url) async {
    if (url.startsWith("http://") && !_unsafeSetting.getValue()) {
      return false;
    }

    // Trust if it's the own server
    if (basePath.contains(url)) {
      return true;
    }

    final domain = extractDomain(url);
    final type = _trustModeSetting.getValue();
    if (type == 0) {
      return true;
    } else if (type == 2) {
      return false;
    }

    if (domain == "") {
      return false;
    }

    final result = await (db.trustedLink.select()..where((tbl) => tbl.domain.contains(domain))).getSingleOrNull();
    if (result == null) {
      return false;
    }

    return true;
  }

  /// Extract between the first "//" and the first "/" to get the domain
  static String extractDomain(String url) {
    final args = url.split("/");
    if (args.length < 3) {
      return "";
    }
    return args[2];
  }
}

/// Method for testing the thing
void main() {
  final testCases = ["http://domain.com", "http://www.domain.co.uk", "http://something.domain.com", "http://some.some.some.domain.com/hello_world"];
  for (var testCase in testCases) {
    sendLog(TrustedLinkHelper.extractDomain(testCase));
  }
}
