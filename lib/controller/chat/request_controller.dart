import 'package:get/get.dart';

class RequestController extends GetxController {
  
  final friends = <FriendRequest>[FriendRequest(1, "Test", "tag"),FriendRequest(1, "Test", "tag"),FriendRequest(1, "Test", "tag")].obs;

}

class FriendRequest {
  final int id;
  final String name;
  final String tag;

  FriendRequest(this.id, this.name, this.tag);
  FriendRequest.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        tag = json["tag"];
}