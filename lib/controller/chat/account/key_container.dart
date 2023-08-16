part of 'friend_controller.dart';

class KeyStorage {
  SecureKey profileKey;
  Uint8List publicKey;
  
  KeyStorage.empty() : publicKey = Uint8List(0), profileKey = randomSymmetricKey();
  KeyStorage(this.publicKey, this.profileKey);
  KeyStorage.fromJson(Map<String, dynamic> json) 
        : publicKey = unpackagePublicKey(json["pub"]),
          profileKey = unpackageSymmetricKey(json["pf"]);
  
  Map<String, dynamic> toJson() {
    return {
      "pub": packagePublicKey(publicKey),
      "pf": packageSymmetricKey(profileKey),
    };
  } 
}