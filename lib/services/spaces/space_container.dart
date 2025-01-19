import 'dart:async';
import 'dart:convert';
import 'package:chat_interface/util/web.dart';
import 'package:http/http.dart' as http;

import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpaceConnectionContainer extends ShareContainer {
  final String node; // Node domain
  final String roomId; // Token required for joining (even though it's not really a token)
  final SecureKey key; // Symmetric key

  final info = Rx<SpaceInfo?>(null);
  int errorCount = 0;
  Timer? _timer;
  bool get cancelled => _timer == null;

  SpaceConnectionContainer(this.node, this.roomId, this.key, Friend? sender) : super(sender, ShareType.space);
  SpaceConnectionContainer.fromJson(Map<String, dynamic> json, [Friend? sender])
      : this(json["node"], json["id"], unpackageSymmetricKey(json["key"]), sender);

  @override
  Map<String, dynamic> toMap() {
    return {"node": node, "id": roomId, "key": packageSymmetricKey(key)};
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
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
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
    info.value = SpaceInfo.fromJson(this, body);
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
    final controller = Get.find<FriendController>();
    for (var member in members) {
      final friend = controller.friends[member];
      if (friend != null) friends.add(friend);
    }
  }

  SpaceInfo.fromJson(SpaceConnectionContainer container, Map<String, dynamic> json) {
    start = DateTime.fromMillisecondsSinceEpoch(json["start"]);
    members = List<LPHAddress>.from(json["members"].map((e) => LPHAddress.from(decryptSymmetric(e, container.key))));
    exists = true;

    final controller = Get.find<FriendController>();

    for (var member in members) {
      final friend = controller.friends[member];
      if (friend != null) friends.add(friend);
    }
  }

  SpaceInfo.notLoaded({bool wasError = false}) {
    exists = false;
    error = wasError;
    members = [];
  }
}
