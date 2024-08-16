import 'dart:convert';

import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/util/web.dart';

import '../../../database/database.dart';

var connectedCluster = Cluster(0, "name", "country");

class ClusterSetup extends ConnectionStep {
  ClusterSetup() : super('loading.cluster');

  @override
  Future<SetupResponse> load() async {
    var cluster = await (db.select(db.setting)..where((tbl) => tbl.key.equals("cluster"))).getSingleOrNull();

    // Check if cluster exists
    if (cluster == null) {
      // Get cluster from the server
      final body = await postAuthorizedJSON("/cluster/list", <String, dynamic>{});
      if (!body["success"]) {
        return SetupResponse(error: body["error"]);
      }

      var clusters = body["clusters"] as List;
      if (clusters.isEmpty) {
        return SetupResponse(error: "not.setup");
      }

      // Set cluster from server
      cluster = SettingData(key: "cluster", value: Cluster.fromJson(clusters[0]).toJson());
      await db.into(db.setting).insertOnConflictUpdate(cluster);
      connectedCluster = Cluster.fromJson(clusters[0]);
    } else {
      // Set cluster from client database
      connectedCluster = Cluster.fromJson(jsonDecode(cluster.value));
    }

    return SetupResponse();
  }
}

class Cluster {
  final int id;
  final String name;
  final String country;

  Cluster(this.id, this.name, this.country);
  Cluster.fromJson(dynamic cluster) : this(cluster["id"], cluster["name"], cluster["country"]);

  String toJson() => jsonEncode(
        {
          "id": id,
          "name": name,
          "country": country,
        },
      );
}
