part of 'friend_controller.dart';

abstract class KeyStorage {
  KeyStorage.empty();
  KeyStorage.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  int protocolVersion();
}

class KeyStorageV1 extends KeyStorage {

  Uint8List publicKey;

  KeyStorageV1.empty() : publicKey = Uint8List(0), super.empty();
  KeyStorageV1.fromJson(Map<String, dynamic> json) : publicKey = unpackagePublicKey(json["pub"]), super.fromJson(json);

  @override
  int protocolVersion() => 1;
  
  @override
  Map<String, dynamic> toJson() {
    return {
      "pub": packagePublicKey(publicKey),
    };
  } 

}
