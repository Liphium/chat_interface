import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/services/chat/status_service.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/util/web.dart';
import 'package:signals/signals_flutter.dart';

class StatusController {
  static String ownAccountId = "";
  static List<String> permissions = [];
  static List<RankData> ranks = [];
  static LPHAddress get ownAddress => LPHAddress(basePath, ownAccountId);

  /// Timer for constantly sending the status
  static Timer? _timer;

  /// Start a timer that always sends the status to the server.
  static void init() {
    if (_timer != null) _timer!.cancel();

    // Update status every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (connector.isConnected()) {
        StatusService.sendStatus();
      }
    });
  }

  static final displayName = signal("not-set");
  static final name = signal('not-set');

  // Status message
  static final statusLoading = signal(true);
  static final status = signal("");
  static final type = signal(1);

  // Shared content by friends
  static final sharedContent = mapSignal(<LPHAddress, ShareContainer>{});

  // Current shared content (by this account)
  static final ownContainer = signal<ShareContainer?>(null);

  void setName(String value) => name.value = value;

  /// Get the current status json for the current client.
  static String statusJson() => jsonEncode(<String, dynamic>{
        "s": base64Encode(utf8.encode(status.peek())),
        "t": type.peek(),
      });

  /// Create a new status json.
  static String newStatusJson(String status, int type) => jsonEncode(<String, dynamic>{
        "s": base64Encode(utf8.encode(status)),
        "t": type,
      });

  /// Update the status from a status json.
  static void fromStatusJson(String json) {
    // Decode the status
    final data = jsonDecode(json);

    // Start a batch to set the new status
    batch(() {
      try {
        status.value = utf8.decode(base64Decode(data["s"]));
      } catch (e) {
        status.value = "";
      }
      type.value = data["t"] ?? 1;
    });
  }

  /// Get the encrypted version of the status json.
  static String statusPacket([String? newStatusJson]) {
    return encryptSymmetric(newStatusJson ?? statusJson(), profileKey);
  }

  /// Get the encrypted version of the currently shared content.
  static String sharedContentPacket() {
    if (ownContainer.value == null) {
      return "";
    }
    return encryptSymmetric(ownContainer.value!.toJson(), profileKey);
  }

  /// Share a new [ShareContainer].
  static Future<bool> share(ShareContainer container) async {
    if (ownContainer.value != null) return false; // TODO: Potentially remove
    ownContainer.value = container;
    await StatusService.sendStatus();
    return true;
  }

  /// Stop sharing the current [ShareContainer].
  static void stopSharing() {
    if (ownContainer.value == null) {
      return;
    }
    ownContainer.value = null;
    StatusService.sendStatus();
  }

  /// Update the current status.
  static void updateStatus({String? message, int? type}) {
    batch(() {
      if (message != null) status.value = message;
      if (type != null) StatusController.type.value = type;
    });
  }
}

enum ShareType { space }

abstract class ShareContainer {
  final Friend? sender;
  final ShareType type;

  ShareContainer(this.sender, this.type);

  Map<String, dynamic> toMap();

  String toJson() {
    final map = toMap();
    map["type"] = type.index;
    return jsonEncode(map);
  }

  void onDrop() {}
}

class RankData {
  int id;
  String name;
  int level;

  RankData({
    required this.id,
    required this.name,
    required this.level,
  });

  // Factory constructor to create Rank object from JSON
  factory RankData.fromJson(Map<String, dynamic> json) {
    return RankData(
      id: json['id'] as int,
      name: json['name'] as String,
      level: json['level'] as int,
    );
  }

  // Method to convert Rank object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
    };
  }
}
