import 'package:get/get.dart';

class RequestController extends GetxController {

  final requests = <Request>[].obs;

}

class Request {

  final String name;
  final String tag;
  final int id;

  Request(this.name, this.tag, this.id);
  Request.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        tag = json["tag"],
        id = json["id"];

}