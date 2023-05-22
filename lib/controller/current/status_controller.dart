import 'package:get/get.dart';

class StatusController extends GetxController {

  final name = 'test'.obs;
  final tag = 'hi'.obs;
  final id = '0'.obs;
  final status = 'online'.obs;

  void setName(String value) => name.value = value;
  void setTag(String value) => tag.value = value;
  void setId(String value) => id.value = value;
  void setStatus(String value) => status.value = value;

}