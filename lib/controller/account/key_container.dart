part of 'friend_controller.dart';

class KeyStorage {
  SecureKey profileKey;
  String storedActionKey;
  Uint8List publicKey;
  
  KeyStorage.empty() : publicKey = Uint8List(0), profileKey = randomSymmetricKey(), storedActionKey = "hello_world";
  KeyStorage(this.publicKey, this.profileKey, this.storedActionKey);
  KeyStorage.fromJson(Map<String, dynamic> json) 
        : publicKey = unpackagePublicKey(json["pub"]),
          profileKey = unpackageSymmetricKey(json["pf"]),
          storedActionKey = json["sa"] ?? "";
  
  Map<String, dynamic> toJson() {
    return {
      "pub": packagePublicKey(publicKey),
      "pf": packageSymmetricKey(profileKey),
      "sa": storedActionKey
    };
  } 
}