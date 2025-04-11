import 'dart:typed_data';

import 'package:chat_interface/util/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/util/encryption/hash.dart';
import 'package:chat_interface/util/encryption/signatures.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:sodium_libs/sodium_libs.dart';

class ServerStoredInfo {
  final bool error;
  final String text;

  ServerStoredInfo(this.text, {this.error = false});

  /// Decrypt stored stored info with own public and private key
  factory ServerStoredInfo.untransform(String transformed, {Sodium? sodium, KeyPair? ownKeyPair}) {
    final result = decryptAsymmetricAuth(
      (ownKeyPair ?? asymmetricKeyPair).publicKey,
      (ownKeyPair ?? asymmetricKeyPair).secretKey,
      transformed,
      sodium,
    );
    return ServerStoredInfo(result.message, error: !result.success);
  }

  /// Get the server stored info in encrypted form with the own public and private key
  String transform({Sodium? sodium, KeyPair? ownKeyPair}) {
    return encryptAsymmetricAuth((ownKeyPair ?? asymmetricKeyPair).publicKey, (ownKeyPair ?? asymmetricKeyPair).secretKey, text, sodium);
  }
}

/// A helper class to encrypt a text using asymmetric sodium and sign it (with a sequence number, can also be the time) to prevent replay attacks
class AsymmetricSequencedInfo {
  final bool error;
  final int seq;
  final String signature;
  final String text;

  AsymmetricSequencedInfo(this.seq, this.signature, this.text, {this.error = false});

  /// Start building a new sequenced info
  factory AsymmetricSequencedInfo.builder(String text, int seq) {
    final hash = hashSha(text + seq.toString());
    final signature = signMessage(signatureKeyPair.secretKey, hash);
    return AsymmetricSequencedInfo(seq, signature, text);
  }

  /// Returns the actual thing that can be sent around
  String finish(Uint8List publicKey) => "$seq:$signature:${encryptAsymmetricAnonymous(publicKey, text)}";

  /// Untransform time encrypted info using secret keys
  factory AsymmetricSequencedInfo.extract(String transformed) {
    final args = transformed.split(":");

    // Check if the thing is in the correct format (somewhat)
    if (args.length != 3) {
      return AsymmetricSequencedInfo(0, "", "", error: true);
    }

    // Check if the sequence number is actually there
    final seq = int.tryParse(args[0]);
    if (seq == null) {
      return AsymmetricSequencedInfo(0, "", "", error: true);
    }

    // Get all the rest
    final signature = args[1];
    final decryptedText = decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, args[2]);
    return AsymmetricSequencedInfo(seq, signature, decryptedText);
  }

  /// Verifies the signature of the sequenced info
  bool verifySignature(Uint8List signaturePub) {
    final computedSignature = hashSha(text + seq.toString());
    return checkSignature(signature, signaturePub, computedSignature);
  }
}

/// A helper class to encrypt a text using symmetric sodium and sign it (with a sequence number, can also be the time) to prevent replay attacks
class SymmetricSequencedInfo {
  final bool error;
  final int seq;
  final String signature;
  final String text;

  SymmetricSequencedInfo(this.seq, this.signature, this.text, {this.error = false});

  /// Start building a new sequenced info
  factory SymmetricSequencedInfo.builder(String text, int seq) {
    final hash = hashSha(text + seq.toString());
    final signature = signMessage(signatureKeyPair.secretKey, hash);
    return SymmetricSequencedInfo(seq, signature, text);
  }

  /// Returns the actual thing that can be sent around
  String finish(SecureKey key, {Sodium? sodium}) => "$seq:$signature:${encryptSymmetric(text, key, sodium)}";

  /// Untransform time encrypted info using the secret key
  factory SymmetricSequencedInfo.extract(String transformed, SecureKey key, [Sodium? sodium]) {
    final args = transformed.split(":");

    // Check if the thing is in the correct format (somewhat)
    if (args.length != 3) {
      return SymmetricSequencedInfo(0, "", "", error: true);
    }

    // Check if the sequence number is actually there
    final seq = int.tryParse(args[0]);
    if (seq == null) {
      return SymmetricSequencedInfo(0, "", "", error: true);
    }

    // Get all the rest
    final signature = args[1];
    final decryptedText = decryptSymmetric(args[2], key, sodium);
    return SymmetricSequencedInfo(seq, signature, decryptedText);
  }

  /// Verifies the signature of the sequenced info
  bool verifySignature(Uint8List signaturePub, [Sodium? sodium]) {
    final computedSignature = hashSha(text + seq.toString());
    return checkSignature(signature, signaturePub, computedSignature, sodium);
  }
}
