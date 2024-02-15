import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/pages/settings/security/trusted_links_settings.dart';
import 'package:chat_interface/util/logging_framework.dart';
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

  static const trustedProviders = [
    "google.com",
    "tenor.com",
    "youtube.com",
    "youtu.be",
    "github.com",
    "google.de",
  ];

  static void init() {
    final controller = Get.find<SettingController>();
    _unsafeSetting = controller.settings[TrustedLinkSettings.unsafeSources]!;
    _trustModeSetting = controller.settings[TrustedLinkSettings.trustMode]!;
  }

  static Future<bool> isLinkTrusted(String url) async {
    if (url.startsWith("http://") && _unsafeSetting.getOr(true)) {
      return false;
    }

    final type = _trustModeSetting.getValue();
    if (type == 0) {
      return true;
    } else if (type == 3) {
      return false;
    } else if (type == 1) {
      // TODO: Trusted list of providers
      return false;
    }

    final domain = extractDomain(url);
    final result = await (db.trustedLink.select()..where((tbl) => tbl.domain.contains(domain))).getSingleOrNull();
    if (result == null) {
      return false;
    }

    return true;
  }

  static String extractDomain(String url) {
    // Remove the protocol part if present
    String domain = url.startsWith('http://') ? url.substring(7) : url;
    domain = domain.startsWith('https://') ? domain.substring(8) : domain;

    // Remove www if present
    if (domain.startsWith('www.')) {
      domain = domain.substring(4);
    }

    // Extract domain by taking characters until the first '/'
    int index = domain.indexOf('/');
    if (index != -1) {
      domain = domain.substring(0, index);
    }

    // Extract domain by considering only the last three segments
    List<String> parts = domain.split('.');
    if (parts.length > 3) {
      domain = parts.getRange(parts.length - 3, parts.length).join('.');
    }

    return domain;
  }
}

/// Method for testing the thing
void main() {
  final testCases = ["http://domain.com", "http://www.domain.com.uk", "http://something.domain.com", "http://some.some.some.domain.com/hello_world"];
  for (var testCase in testCases) {
    sendLog(TrustedLinkHelper.extractDomain(testCase));
  }
}
