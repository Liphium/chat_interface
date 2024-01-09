part of 'friend_controller.dart';

class KeyStorage {
  SecureKey profileKey;
  String storedActionKey;
  Uint8List publicKey;
  Uint8List signatureKey;
  
  KeyStorage.empty() : publicKey = Uint8List(0), signatureKey = Uint8List(0), profileKey = randomSymmetricKey(), storedActionKey = "hello_world";
  KeyStorage(this.publicKey, this.signatureKey, this.profileKey, this.storedActionKey);
  KeyStorage.fromJson(Map<String, dynamic> json) 
        : publicKey = unpackagePublicKey(json["pub"]),
          profileKey = unpackageSymmetricKey(json["pf"]),
          signatureKey = unpackagePublicKey(json["sg"]),
          storedActionKey = json["sa"] ?? "";
  
  Map<String, dynamic> toJson() {
    return {
      "pub": packagePublicKey(publicKey),
      "pf": packageSymmetricKey(profileKey),
      "sg": packagePublicKey(signatureKey),
      "sa": storedActionKey
    };
  } 
}