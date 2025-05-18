// Public key packaging
import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_interface/src/rust/api/encryption.dart';
import 'package:sodium_libs/sodium_libs.dart';

Future<String?> packagePublicKey(PublicKey publicKey) async {
  final bytes = await encodePublicKey(key: publicKey);
  return bytes != null ? base64Encode(bytes) : null;
}

Future<String?> packageAndDropPublicKey(PublicKey publicKey) async {
  final bytes = await encodeAndDropPublicKey(key: publicKey);
  return bytes != null ? base64Encode(bytes) : null;
}

Future<PublicKey?> unpackagePublicKey(String publicKey) async {
  return await decodePublicKey(data: base64Decode(publicKey));
}

// Secret key packaging
Future<String?> packageSecretKey(SecretKey secretKey) async {
  final bytes = await encodeSecretKey(key: secretKey);
  return bytes != null ? base64Encode(bytes) : null;
}

Future<String?> packageAndDropSecretKey(SecretKey secretKey) async {
  final bytes = await encodeAndDropSecretKey(key: secretKey);
  return bytes != null ? base64Encode(bytes) : null;
}

Future<SecretKey?> unpackageSecretKey(String secretKey) async {
  return await decodeSecretKey(data: base64Decode(secretKey));
}

// Verifying key packaging
Future<String?> packageVerifyingKey(VerifyingKey verifyingKey) async {
  final bytes = await encodeVerifyingKey(key: verifyingKey);
  return bytes != null ? base64Encode(bytes) : null;
}

Future<String?> packageAndDropVerifyingKey(VerifyingKey verifyingKey) async {
  final bytes = await encodeAndDropVerifyingKey(key: verifyingKey);
  return bytes != null ? base64Encode(bytes) : null;
}

Future<VerifyingKey?> unpackageVerifyingKey(String verifyingKey) async {
  return await decodeVerifyingKey(data: base64Decode(verifyingKey));
}

// Signing key packaging
Future<String?> packageSigningKey(SigningKey signingKey) async {
  final bytes = await encodeSigningKey(key: signingKey);
  return bytes != null ? base64Encode(bytes) : null;
}

Future<String?> packageAndDropSigningKey(SigningKey signingKey) async {
  final bytes = await encodeAndDropSigningKey(key: signingKey);
  return bytes != null ? base64Encode(bytes) : null;
}

Future<SigningKey?> unpackageSigningKey(String signingKey) async {
  return await decodeSigningKey(data: base64Decode(signingKey));
}

// Symmetric key packaging
Future<String?> packageSymmetricKey(SymmetricKey symmetricKey) async {
  final bytes = await encodeSymmetricKey(key: symmetricKey);
  return bytes != null ? base64Encode(bytes) : null;
}

Future<String?> packageAndDropSymmetricKey(SymmetricKey symmetricKey) async {
  final bytes = await encodeAndDropSymmetricKey(key: symmetricKey);
  return bytes != null ? base64Encode(bytes) : null;
}

Future<SymmetricKey?> unpackageSymmetricKey(String symmetricKey) async {
  return await decodeSymmetricKey(data: base64Decode(symmetricKey));
}

Uint8List packToBytes(String message) {
  return message.toCharArray().unsignedView();
}

String? unpackFromBytes(Uint8List bytes) {
  try {
    return utf8.decode(bytes);
  } catch (_) {
    return null;
  }
}

Uint8List? decodeFromBase64(String message) {
  try {
    return base64Decode(message);
  } catch (_) {
    return null;
  }
}
