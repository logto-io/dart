import 'package:flutter_test/flutter_test.dart';

import 'package:logto_dart_sdk/src/utilities/pkce.dart';

void main() {
  test(' Generate PKCE pair', () {
    PKCE pkce = PKCE.generate();

    expect(pkce.codeChallenge, isNotNull);
    expect(pkce.codeVerifier, isNotNull);
    expect(PKCE.generateCodeChallenge(pkce.codeVerifier), pkce.codeChallenge);
  });
}
