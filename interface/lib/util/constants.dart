//* These will be loaded from the server (in the future)
final Map<String, dynamic> specialConstants = <String, dynamic>{
  "max_conversation_amount": 500,
  "max_conversation_name_length": 50,
  "max_conversation_members": 100,
};

//* These are just normal constants
class Constants {
  // Vault
  static const String conversationTag = "c";
  static const String deckTag = "d";

  // Errors
  static const String unknownError = "error.unknown";
  static const String unknownErrorText = "error.unknown.text";

  // Limits
  static const int normalNameLimit = 50;
  static const int maxDecks = 10;
}
