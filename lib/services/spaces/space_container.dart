import 'dart:async';
import 'dart:convert';
import 'package:chat_interface/src/rust/api/encryption.dart';
import 'package:chat_interface/util/encryption/packing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:http/http.dart' as http;

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:signals/signals_flutter.dart';

class SpaceConnectionContainer extends ShareContainer {
  final String node; // Node domain
  final String roomId; // Token required for joining (even though it's not really a token)
  final SymmetricKey key; // Symmetric key

  final info = signal<SpaceInfo?>(null);
  int errorCount = 0;
  Timer? _timer;
  bool get cancelled => _timer == null;

  SpaceConnectionContainer(this.node, this.roomId, this.key, Friend? sender) : super(sender, ShareType.space);
  static Future<SpaceConnectionContainer?> fromJson(Map<String, dynamic> json, [Friend? sender]) async {
    final unpacked = await unpackageSymmetricKey(json["key"]);
    if (unpacked == null) {
      return null;
    }
    return SpaceConnectionContainer(json["node"], json["id"], unpacked, sender);
  }

  @override
  Future<Map<String, dynamic>> toMap() async {
    return {"node": node, "id": roomId, "key": await packageSymmetricKey(key)};
  }

  String toInviteJson() => jsonEncode({"node": node, "id": roomId, "key": packageSymmetricKey(key)});

  @override
  void onDrop() {
    _timer?.cancel();
  }

  Future<SpaceInfo> getInfo({bool timer = false}) async {
    // Request the info from the server
    final http.Response req;
    try {
      req = await http.post(
        Uri.parse("${nodeProtocol()}$node/info"),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({"room": roomId}),
      );
    } catch (e) {
      return SpaceInfo.notLoaded(wasError: true);
    }

    // Return a not loaded state if the request wasn't successful
    if (req.statusCode != 200) {
      return SpaceInfo.notLoaded(wasError: true);
    }

    // Parse the json
    final body = jsonDecode(req.body);

    // Start a periodic timer to refresh info (if desired)
    if (timer && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        final newInfo = await getInfo();
        if (!newInfo.exists) {
          errorCount++;
          if (errorCount > 2) {
            _timer?.cancel();
            _timer = null;
          }
        }
        info.value = newInfo;
      });
    }

    // Return a not loaded state if the request wasn't successful
    if (!body["success"]) {
      return SpaceInfo.notLoaded();
    }

    // Return the proper info
    info.value = await SpaceInfo.fromJson(this, body);
    return info.value!;
  }
}

class SpaceInfo {
  late bool exists;
  bool error = false;
  late DateTime start;
  final List<Friend> friends = [];
  late final List<LPHAddress> members;

  SpaceInfo(this.start, this.members) {
    error = false;
    exists = true;
    for (var member in members) {
      final friend = FriendController.friends[member];
      if (friend != null) friends.add(friend);
    }
  }

  static Future<SpaceInfo> fromJson(SpaceConnectionContainer container, Map<String, dynamic> json) async {
    final decryptedMembers = await Future.wait(
      json["members"].map((e) => decryptSymmetricBase64String(container.key, e)),
    );
    final addresses = decryptedMembers.map((e) => LPHAddress.from(e ?? "")).toList();

    final info = SpaceInfo(DateTime.fromMillisecondsSinceEpoch(json["start"]), addresses);
    info.exists = true;

    for (var member in info.members) {
      final friend = FriendController.friends[member];
      if (friend != null) info.friends.add(friend);
    }
    return info;
  }

  SpaceInfo.notLoaded({bool wasError = false}) {
    exists = false;
    error = wasError;
    members = [];
  }
}
