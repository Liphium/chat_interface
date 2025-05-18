import 'dart:convert';

import 'package:chat_interface/src/rust/api/encryption.dart';
import 'package:chat_interface/util/encryption/packing.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:get/get_utils/get_utils.dart';

class ServerStoredInfo {
  final bool error;
  final String text;

  ServerStoredInfo(this.text, {this.error = false});

  /// Decrypt stored stored info with own public and private key
  static Future<ServerStoredInfo> untransform(String transformed) async {
    // Make sure the thing is decodable
    final decoded = decodeFromBase64(transformed);
    if (decoded == null) {
      return ServerStoredInfo("", error: true);
    }

    // Decrypt the container
    final result = await decryptAsymmetricContainer(
      publicKey: asymmetricKeyPair.publicKey,
      secretKey: asymmetricKeyPair.secretKey,
      verifyingKey: signatureKeyPair.verifyingKey,
      ciphertext: decoded,
    );
    if (result == null) {
      return ServerStoredInfo("", error: true);
    }
    final unpacked = unpackFromBytes(result);
    return ServerStoredInfo(unpacked ?? "", error: unpacked == null);
  }

  /// Get the server stored info in encrypted form with the own public and private key
  Future<String?> transform() async {
    final container = await encryptAsymmetricContainer(
      publicKey: asymmetricKeyPair.publicKey,
      signingKey: signatureKeyPair.signingKey,
      message: packToBytes(text),
    );
    if (container == null) {
      return null;
    }
    return base64Encode(container);
  }
}

/// A helper class to encrypt a text using symmetric sodium and sign it (with a sequence number, can also be the time) to prevent replay attacks
class SymmetricSequencedInfo {
  final bool error;
  final String text;

  SymmetricSequencedInfo(this.text, {this.error = false});

  /// Generate a new [SymmetricSequenceInfo] in encoded form.
  static Future<String> generate(int seq, String text, SymmetricKey key) async {
    return base64Encode(
      (await encryptSymmetricContainer(
        key: key,
        signingKey: signatureKeyPair.signingKey,
        message: packToBytes(text),
        salt: packToBytes(seq.toString()),
      ))!,
    );
  }

  /// Untransform time encrypted info using the secret key
  static Future<SymmetricSequencedInfo> extract(
    String transformed,
    int seq,
    SymmetricKey key,
    VerifyingKey verifyingKey,
  ) async {
    // Try untransforming
    final unpacked = decodeFromBase64(transformed);
    if (unpacked == null) {
      return SymmetricSequencedInfo("", error: true);
    }

    // Try decrypting the container
    final container = await decryptSymmetricContainer(
      key: key,
      verifyingKey: verifyingKey,
      ciphertext: unpacked,
      salt: packToBytes(seq.toString()),
    );
    if (container == null) {
      return SymmetricSequencedInfo("encryption.error".tr, error: true);
    }
    final unpackedText = unpackFromBytes(container);
    if (unpackedText == null) {
      return SymmetricSequencedInfo("unpacking.error".tr, error: true);
    }
    return SymmetricSequencedInfo(unpackedText);
  }
}
