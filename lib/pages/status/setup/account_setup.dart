import 'package:chat_interface/pages/status/error/server_offline_page.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';

class AccountSetup extends Setup {
  AccountSetup() : super('loading.account', const ServerOfflinePage());
  
  @override
  Future<bool> load() async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }
}