import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class SyncCryptoException implements Exception {
  SyncCryptoException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// AES-256-GCM with a PBKDF2-HMAC-SHA256 key derived from the passphrase.
/// Derived keys are cached per salt so each peer costs one derivation.
class SyncCrypto {
  SyncCrypto(this.passphrase, {this.iterations = 200000});

  final String passphrase;
  final int iterations;
  final _keys = <String, SecretKey>{};
  final _aes = AesGcm.with256bits();
  List<int>? _ownSalt;

  Future<SecretKey> _key(List<int> salt) async {
    final id = base64Encode(salt);
    final cached = _keys[id];
    if (cached != null) return cached;
    final kdf = Pbkdf2(
        macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256);
    final k = await kdf.deriveKeyFromPassword(password: passphrase, nonce: salt);
    _keys[id] = k;
    return k;
  }

  Future<Map<String, dynamic>> encrypt(List<int> plain) async {
    final salt = _ownSalt ??= _random(16);
    final key = await _key(salt);
    final box = await _aes.encrypt(plain, secretKey: key);
    return {
      'format': 'iptv-one-sync-enc',
      'v': 1,
      'kdf': 'pbkdf2-sha256',
      'iter': iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'ct': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    };
  }

  Future<List<int>> decrypt(Map<String, dynamic> env) async {
    final iter = (env['iter'] as num?)?.toInt() ?? iterations;
    final salt = base64Decode(env['salt'] as String);
    final kdfKey = iter == iterations
        ? await _key(salt)
        : await SyncCrypto(passphrase, iterations: iter)._key(salt);
    try {
      return await _aes.decrypt(
        SecretBox(base64Decode(env['ct'] as String),
            nonce: base64Decode(env['nonce'] as String),
            mac: Mac(base64Decode(env['mac'] as String))),
        secretKey: kdfKey,
      );
    } on SecretBoxAuthenticationError {
      throw SyncCryptoException(
          'Wrong sync passphrase (or the file was modified).');
    }
  }

  static List<int> _random(int n) {
    final r = Random.secure();
    return List<int>.generate(n, (_) => r.nextInt(256));
  }
}
