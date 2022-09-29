import 'dart:convert';

import 'package:crypto/crypto.dart';

import '/src/utilities/utils.dart' as utils;

class PKCE {
  final String codeVerifier;
  final String codeChallenge;

  const PKCE._(this.codeVerifier, this.codeChallenge);

  factory PKCE.generate() {
    String codeVerifier = PKCE.generateCodeVerifier();
    String codeChallenge = PKCE.generateCodeChallenge(codeVerifier);

    return PKCE._(codeVerifier, codeChallenge);
  }

  static String generateCodeVerifier() => utils.generateRandomString();

  static String generateCodeChallenge(String codeVerifier) => base64Url
      .encode(sha256.convert(ascii.encode(codeVerifier)).bytes)
      .replaceAll('=', '');
}
