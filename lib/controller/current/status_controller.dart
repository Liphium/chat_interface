import 'package:get/get.dart';

class StatusController extends GetxController {

  final name = ''.obs;
  final tag = ''.obs;

  void setName(String value) => name.value = value;
  void setTag(String value) => tag.value = value;

}