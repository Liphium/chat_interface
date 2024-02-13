import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:drift/drift.dart';

class TrustedLink extends Table {
  TextColumn get domain => text()();

  @override
  Set<Column<Object>>? get primaryKey => {domain};
}

class TrustedLinkHelper {
  static Future<bool> isLinkTrusted(String url) async {
    if (url.startsWith("http://")) {
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
