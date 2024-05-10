import 'dart:typed_data';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';

class ServerStoredInfo {
  final bool error;
  final String text;

  ServerStoredInfo(this.text, {this.error = false});

  /// Decrypt stored stored info with own public and private key
  factory ServerStoredInfo.untransform(String transformed) {
    final result = decryptAsymmetricAuth(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, transformed);
    return ServerStoredInfo(result.message, error: !result.success);
  }

  /// Get the server stored info in encrypted form with the own public and private key
  String transform() => encryptAsymmetricAuth(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, text);
}

/// A helper class to encrypt a text and sign it (with a sequence number, can also be the time) to prevent replay attacks
class SequencedInfo {
  final bool error;
  final int seq;
  final String signature;
  final String text;

  SequencedInfo(this.seq, this.signature, this.text, {this.error = false});

  /// Start building a new sequenced info
  factory SequencedInfo.builder(String text, int seq) {
    final hash = hashSha(text + seq.toString());
    final signature = signMessage(signatureKeyPair.secretKey, hash);
    return SequencedInfo(seq, signature, text);
  }

  /// Returns the actual thing that can be sent around
  String finish(Uint8List publicKey) => "$seq:$signature:${encryptAsymmetricAnonymous(publicKey, text)}";

  /// Untransform time encrypted info using secret keys
  factory SequencedInfo.extract(String transformed) {
    final args = transformed.split(":");

    // Check if the thing is in the correct format (somewhat)
    if (args.length != 3) {
      return SequencedInfo(0, "", "", error: true);
    }

    // Check if the sequence number is actually there
    final seq = int.tryParse(args[0]);
    if (seq == null) {
      return SequencedInfo(0, "", "", error: true);
    }

    // Get all the rest
    final signature = args[1];
    final decryptedText = decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, args[2]);
    return SequencedInfo(seq, signature, decryptedText);
  }

  /// Verifies the signature of the sequenced info
  bool verifySignature(Uint8List signaturePub) {
    final computedSignature = hashSha(text + seq.toString());
    return checkSignature(signature, signaturePub, computedSignature);
  }
}
