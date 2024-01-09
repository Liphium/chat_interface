import 'dart:convert';

import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../database/database.dart';
import '../../../../util/vertical_spacing.dart';

var connectedCluster = Cluster(0, "name", "country");

class ClusterSetup extends Setup {
  ClusterSetup() : super('loading.cluster', false);

  @override
  Future<Widget?> load() async {

    // Get cluster from database
    var clusters = await (db.select(db.setting)..where((tbl) => tbl.key.equals("cluster"))).get();
    if(clusters.isEmpty) {
      return const ClusterSelectionPage();
    }
    if(clusters.first.value.length < 5) {
      return const ClusterSelectionPage();
    }

    connectedCluster = Cluster.fromJson(jsonDecode(clusters.first.value));

    return null;
  }
}

class ClusterSelectionPage extends StatefulWidget {
  const ClusterSelectionPage({super.key});

  @override
  State<ClusterSelectionPage> createState() => _ClusterSelectionPageState();
}

class Cluster {
  final int id;
  final String name;
  final String country;

  Cluster(this.id, this.name, this.country);
  Cluster.fromJson(dynamic cluster) : this(cluster["id"], cluster["name"], cluster["country"]);

  String toJson() => jsonEncode({
    "id": id,
    "name": name,
    "country": country,
  });
}

class _ClusterSelectionPageState extends State<ClusterSelectionPage> {

  @override
  void initState() {
  
    fetchClusters();
    super.initState();
  }
 
  final loading = true.obs;
  final clusters = <Cluster>[];

  void fetchClusters() async {

    // Send request
    final body = await postAuthorizedJSON("/cluster/list", <String, dynamic>{});
    if(!body["success"]) {
      setupManager.error(body["error"]);
      return;
    }

    var clusters = body["clusters"] as List;
    for (var cluster in clusters) {
      this.clusters.add(Cluster.fromJson(cluster));
    }

    loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Obx(() => loading.value ? const LinearProgressIndicator(minHeight: 10,) :
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('setup.choose'.tr),
              verticalSpacing(defaultSpacing),
              ListView.builder(
                shrinkWrap: true,
                itemCount: clusters.length,
                itemBuilder: (context, index) {
                  var cluster = clusters[index];
                  return ElevatedButton(
                    onPressed: () async {
                      loading.value = true;
                      await db.into(db.setting).insertOnConflictUpdate(SettingData(key: "cluster", value: cluster.toJson()));
                      connectedCluster = cluster;
                      setupManager.next();
                    },
                    child: Text("${cluster.name} (${cluster.country})"),
                  );
                },
              )
            ],
          )
        ))
      )
    );
  }
}