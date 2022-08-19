import 'package:flutter_test/flutter_test.dart';

import 'package:logto_dart_sdk/logto_core.dart';
import 'package:logto_dart_sdk/src/utilities/constants.dart';

void main() {
  test('Generate SignIn Uri', () {
    const String authorizationEndpoint = 'http://foo.com';
    const clientId = 'foo_client';
    var redirectUri = Uri.parse('http://foo.app.io');
    const String codeChallenge = 'foo_code_challenge';
    const String state = 'foo_state';

    var signInUri = LogtoCore.generateSignInUri(
        authorizationEndpoint: authorizationEndpoint,
        clientId: clientId,
        redirectUri: redirectUri,
        codeChallenge: codeChallenge,
        state: state);

    expect(signInUri.scheme, 'http');
    expect(signInUri.host, 'foo.com');
    expect(signInUri.queryParameters, containsPair('client_id', clientId));
    expect(signInUri.queryParameters,
        containsPair('redirect_uri', 'http://foo.app.io'));
    expect(signInUri.queryParameters,
        containsPair('code_challenge', codeChallenge));
    expect(signInUri.queryParameters,
        containsPair('code_challenge_method', LogtoCore.codeChallengeMethod));
    expect(signInUri.queryParameters, containsPair('state', state));
    expect(signInUri.queryParameters,
        containsPair('scope', reservedScopes.join(' ')));
    expect(signInUri.queryParameters,
        containsPair('response_type', LogtoCore.responseType));
    expect(signInUri.queryParameters, containsPair('prompt', LogtoCore.prompt));
  });

  test('Generate SignOut Uri', () {
    const String endSessionEndpoint = 'https://foo.com';
    const String idToken = 'foo_id_token';
    const String postLogoutRedirectUri = 'http://foo.app.io';

    var signOutUri = LogtoCore.generateSignOutUri(
        endSessionEndpoint: endSessionEndpoint,
        idToken: idToken,
        postLogoutRedirectUri: Uri.parse(postLogoutRedirectUri));

    expect(signOutUri.scheme, 'https');
    expect(signOutUri.host, 'foo.com');
    expect(signOutUri.queryParameters, containsPair('id_token_hint', idToken));
    expect(signOutUri.queryParameters,
        containsPair('post_logout_redirect_uri', postLogoutRedirectUri));
  });
}
