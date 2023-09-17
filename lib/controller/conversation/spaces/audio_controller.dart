import 'package:get/get.dart';

class AudioController extends GetxController {
  
  //* Output
  final outputLoading = false.obs;
  final output = false.obs;

  void setOutput(bool newOutput) {
    output.value = newOutput;
  }

  //* Input
  final microphoneLoading = false.obs;
  final microphone = false.obs;

  void setMicrophone(bool newMicrophone) {
    microphone.value = newMicrophone;
  }

  void _onChanged() {
  }

  void disconnect() {
  }
}