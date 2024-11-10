// Templates for functions implemented by native and web

import 'package:get/get.dart';

class Instance {
  final String name;

  Instance(this.name);
}

Future<String?> loadInstance(String name) async {
  return "not.supported".tr;
}

Future<List<Instance>?> getInstances() async {
  return null;
}

Future<String?> deleteInstance(String name) async {
  return "not.supported".tr;
}
