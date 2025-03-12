import 'package:chat_interface/main.dart';

//* These will be loaded from the server (in the future)
final Map<String, int> specialConstants = <String, int>{
  Constants.specialConstantMaxFileSize: 10 * 1024 * 1024, // in MB
  Constants.specialConstantMaxConversationAmount: 500,
  Constants.specialConstantMaxConversationNameLength: 50,
  Constants.specialConstantMaxConversationMembers: 100,
};

//* These are just normal constants
class Constants {
  // Special constants
  static const String specialConstantMaxFileSize = "max_file_size";
  static const String specialConstantMaxConversationAmount = "max_conversation_amount";
  static const String specialConstantMaxConversationNameLength = "max_conversation_name_length";
  static const String specialConstantMaxConversationMembers = "max_conversation_members";

  // Vault
  static const String vaultConversationTag = "$appTag:conv";
  static const String vaultDeckTag = "$appTag:deck";
  static const String vaultLibraryTag = "$appTag:lib";

  // Files
  static const String fileAttachmentTag = "$appTag:attachment";
  static const String fileDeckTag = "$appTag:deck";
  static const String fileAppDataTag = "$appTag:app_data";

  // Errors
  static const String unknownError = "error.unknown";
  static const String unknownErrorText = "error.unknown.text";

  // Limits
  static const int normalNameLimit = 50;
  static const int maxDecks = 10;

  // Documentation
  static const String docsAdminBase = "https://docs.liphium.com";
  static const String docsBase = "https://liphium.com/docs";
  static const String docsUsageFAQ = "https://liphium.com/docs/usage/faq";
  static const String docsEncryptionAndPrivacy = "https://liphium.com//docs/using-liphium/encryption-and-privacy/";
}
