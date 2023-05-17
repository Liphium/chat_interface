import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../../database/database.dart';
import '../../../../main.dart';
import '../../../../util/vertical_spacing.dart';
import '../setup_manager.dart';

class InstanceSetup extends Setup {
  InstanceSetup() : super('loading.instance', true);

  @override
  Future<Widget?> load() async {

    // Get list of instances
    print((await getApplicationSupportDirectory()).path);
    final instanceFolder = path.join((await getApplicationSupportDirectory()).path, "instances");
    final dir = Directory(instanceFolder);

    await dir.create();
    final instances = await dir.list().toList();

    if(instances.isEmpty || !isDebug) {
      setupInstance("default");
      return null;
    }

    // Open instance selection page
    return InstanceSelectionPage(instances: instances);
  }
}

void setupInstance(String name, {bool next = false}) async {

  // Initialize database
  final dbFolder = path.join((await getApplicationSupportDirectory()).path, "instances");
  final file = File(path.join(dbFolder, '$name.db'));
  db = Database(NativeDatabase.createInBackground(file, logStatements: true));

  // Create tables
  var _ = await (db.select(db.setting)).get();

  if(next) {
    setupManager.next(open: true);
  }
}

class InstanceSelectionPage extends StatefulWidget {

  final List<FileSystemEntity> instances;

  const InstanceSelectionPage({super.key, required this.instances});

  @override
  State<InstanceSelectionPage> createState() => _InstanceSelectionPageState();
}

class _InstanceSelectionPageState extends State<InstanceSelectionPage> {

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('setup.choose.instance'.tr),
              verticalSpacing(defaultSpacing),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.instances.length,
                itemBuilder: (context, index) {

                  var instance = widget.instances[index];
                  final base = path.basename(path.withoutExtension(instance.path));

                  return ElevatedButton(
                    onPressed: () => setupInstance(path.basename(path.withoutExtension(instance.path)), next: true),
                    child: Text(base),
                  );
                },
              ),
              verticalSpacing(defaultSpacing),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'setup.instance.name'.tr,
                      ),
                    ),
                  ),
                  verticalSpacing(defaultSpacing),
                  ElevatedButton(
                    onPressed: () => setupInstance(_controller.text, next: true),
                    child: const Text("Create"),
                  )
                ],
              )
            ],
          )
        )
      )
    );
  }
}