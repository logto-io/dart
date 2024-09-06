import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logto_dart_sdk/logto_core.dart';
import 'package:nock/nock.dart';

import 'package:logto_dart_sdk/logto_core.dart' as logto_core;

import 'mocks/responses.dart';

const String logtoOrigin = 'https://logto.dev';

void main() {
  setUpAll(nock.init);

  setUp(() {
    nock.cleanAll();
  });

  const String authorizationEndpoint = 'http://foo.com';
  const clientId = 'foo_client';
  var redirectUri = 'http://foo.app.io';
  const String codeChallenge = 'foo_code_challenge';
  const String state = 'foo_state';

  test('Generate SignIn Uri', () {
    const InteractionMode interactionMode = InteractionMode.signUp;

    var signInUri = logto_core.generateSignInUri(
        authorizationEndpoint: authorizationEndpoint,
        clientId: clientId,
        redirectUri: redirectUri,
        codeChallenge: codeChallenge,
        resources: ['http://foo.api'],
        state: state,
        interactionMode: interactionMode);

    expect(signInUri.scheme, 'http');
    expect(signInUri.host, 'foo.com');
    expect(signInUri.queryParameters, containsPair('client_id', clientId));
    expect(signInUri.queryParameters,
        containsPair('redirect_uri', 'http://foo.app.io'));
    expect(
        signInUri.queryParameters, containsPair('resource', 'http://foo.api'));
    expect(signInUri.queryParameters,
        containsPair('code_challenge', codeChallenge));
    expect(signInUri.queryParameters,
        containsPair('code_challenge_method', 'S256'));
    expect(signInUri.queryParameters, containsPair('state', state));
    expect(signInUri.queryParameters,
        containsPair('scope', reservedScopes.join(' ')));
    expect(signInUri.queryParameters, containsPair('response_type', 'code'));
    expect(signInUri.queryParameters, containsPair('prompt', 'consent'));
    expect(
        signInUri.queryParameters, containsPair('interaction_mode', 'signUp'));
  });

  test('Generate SignIn Uri with organization scope', () {
    var signInUri = logto_core.generateSignInUri(
        authorizationEndpoint: authorizationEndpoint,
        clientId: clientId,
        redirectUri: redirectUri,
        codeChallenge: codeChallenge,
        resources: ['http://foo.api'],
        state: state,
        scopes: [LogtoUserScope.organizations.value]);

    expect(
        signInUri.queryParametersAll,
        containsPair('resource',
            ['http://foo.api', LogtoReservedResource.organization.value]));
  });

  test('Generate SignIn Uri with direct sign in specified', () {
    const String directSignIn = 'social:connector';

    var signInUri = logto_core.generateSignInUri(
        authorizationEndpoint: authorizationEndpoint,
        clientId: clientId,
        redirectUri: redirectUri,
        codeChallenge: codeChallenge,
        resources: ['http://foo.api'],
        state: state,
        directSignIn: directSignIn);

    expect(signInUri.queryParameters,
        containsPair('direct_sign_in', directSignIn));
  });

  test('SignIn Uri with direct sign starting with `social:` passes validation',
      () {
    const String directSignIn = 'social:connector';

    var signInUri = logto_core.generateSignInUri(
        authorizationEndpoint: authorizationEndpoint,
        clientId: clientId,
        redirectUri: redirectUri,
        codeChallenge: codeChallenge,
        resources: ['http://foo.api'],
        state: state,
        directSignIn: directSignIn);

    expect(signInUri.queryParameters,
        containsPair('direct_sign_in', directSignIn));
  });

  test('SignIn Uri with direct sign starting with `sso:` passes validation',
      () {
    const String directSignIn = 'sso:connector';

    var signInUri = logto_core.generateSignInUri(
        authorizationEndpoint: authorizationEndpoint,
        clientId: clientId,
        redirectUri: redirectUri,
        codeChallenge: codeChallenge,
        resources: ['http://foo.api'],
        state: state,
        directSignIn: directSignIn);

    expect(signInUri.queryParameters,
        containsPair('direct_sign_in', directSignIn));
  });

  test('SignIn Uri with direct sign starting with `wrong:` fails validation',
      () {
    const String directSignIn = 'wrong:connector';

    expect(
        () => logto_core.generateSignInUri(
            authorizationEndpoint: authorizationEndpoint,
            clientId: clientId,
            redirectUri: redirectUri,
            codeChallenge: codeChallenge,
            resources: ['http://foo.api'],
            state: state,
            directSignIn: directSignIn),
        throwsA(predicate((e) =>
            e is AssertionError &&
            e.message ==
                'Invalid format for directSignIn: $directSignIn, '
                    'expected one of `social:{connector}` or `sso:{connector}`')));
  });

  test('SignIn Uri with firstScreen and loginHint', () {
    const FirstScreen firstScreen = FirstScreen.identifierRegister;
    const String loginHint = 'foo@logto.io';

    var signInUri = logto_core.generateSignInUri(
        authorizationEndpoint: authorizationEndpoint,
        clientId: clientId,
        redirectUri: redirectUri,
        codeChallenge: codeChallenge,
        state: state,
        firstScreen: firstScreen,
        loginHint: loginHint);

    expect(signInUri.queryParameters,
        containsPair('first_screen', FirstScreen.identifierRegister.value));
    expect(signInUri.queryParameters, containsPair('login_hint', loginHint));
  });

  test('SignIn Uri with firstScreen and identifiers', () {
    const FirstScreen firstScreen = FirstScreen.identifierRegister;
    const List<IdentifierType> identifiers = [
      IdentifierType.email,
      IdentifierType.phone
    ];

    var signInUri = logto_core.generateSignInUri(
        authorizationEndpoint: authorizationEndpoint,
        clientId: clientId,
        redirectUri: redirectUri,
        codeChallenge: codeChallenge,
        state: state,
        firstScreen: firstScreen,
        identifiers: identifiers);

    expect(signInUri.queryParameters,
        containsPair('first_screen', FirstScreen.identifierRegister.value));
    expect(
        signInUri.queryParameters, containsPair('identifier', 'email phone'));
  });

  test('SignIn Uri with extraParams', () {
    const Map<String, String> extraParams = {'foo': 'bar'};

    var signInUri = logto_core.generateSignInUri(
        authorizationEndpoint: authorizationEndpoint,
        clientId: clientId,
        redirectUri: redirectUri,
        codeChallenge: codeChallenge,
        state: state,
        extraParams: extraParams);

    expect(signInUri.queryParameters, containsPair('foo', 'bar'));
  });

  test('Generate SignOut Uri', () {
    const String endSessionEndpoint = 'https://foo.com';
    const String clientId = 'foo_client';
    const String postLogoutRedirectUri = 'http://foo.app.io';

    var signOutUri = logto_core.generateSignOutUri(
        endSessionEndpoint: endSessionEndpoint,
        clientId: clientId,
        postLogoutRedirectUri: Uri.parse(postLogoutRedirectUri));

    expect(signOutUri.scheme, 'https');
    expect(signOutUri.host, 'foo.com');
    expect(signOutUri.queryParameters, containsPair('client_id', clientId));
    expect(signOutUri.queryParameters,
        containsPair('post_logout_redirect_uri', postLogoutRedirectUri));
  });

  test('Fetch OIDC Config', () async {
    const String endpoint = '/oidc/.well-known/openid-configuration';

    final interceptor = nock(logtoOrigin).get(endpoint)
      ..reply(200, jsonEncode(mockOidcConfigResponse),
          headers: {'Content-Type': 'application/json'});

    var result = await logto_core.fetchOidcConfig(
        http.Client(), '$logtoOrigin$endpoint');

    expect(interceptor.isDone, true);
    expect(result.issuer, mockOidcConfigResponse['issuer']);
  });

  test('Fetch Token By Authorization Code', () async {
    const String endpoint = '/oidc/token';
    const String code = 'code';
    const String codeVerifier = 'codeVerifier';
    const String clientId = 'clientId';
    const String redirectUri = 'http://foo.io';
    const String resource = 'resource';

    final interceptor = nock(logtoOrigin).post(endpoint, {
      'grant_type': authorizationCodeGrantType,
      'code': code,
      'code_verifier': codeVerifier,
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'resource': resource
    })
      ..reply(200, mockCodeTokenResponse,
          headers: {'Content-Type': 'application/json'});

    var result = await logto_core.fetchTokenByAuthorizationCode(
        httpClient: http.Client(),
        tokenEndPoint: '$logtoOrigin$endpoint',
        code: code,
        codeVerifier: codeVerifier,
        clientId: clientId,
        redirectUri: redirectUri,
        resource: resource);

    expect(interceptor.isDone, true);
    expect(result.accessToken, mockCodeTokenResponse['access_token']);
  });

  test('Fetch Token By RefreshToken', () async {
    const String endpoint = '/oidc/token';
    const String clientId = 'foo';
    const String refreshToken = 'refreshToken';

    final interceptor = nock(logtoOrigin).post(endpoint, {
      'grant_type': refreshTokenGrantType,
      'client_id': clientId,
      'refresh_token': refreshToken
    })
      ..reply(200, mockRefreshTokenResponse,
          headers: {'Content-Type': 'application/json'});

    var result = await logto_core.fetchTokenByRefreshToken(
        httpClient: http.Client(),
        tokenEndPoint: '$logtoOrigin$endpoint',
        clientId: clientId,
        refreshToken: refreshToken);

    expect(interceptor.isDone, true);
    expect(result.refreshToken, mockRefreshTokenResponse['refresh_token']);
  });

  test('Fetch UserInfo should return all valid fields', () async {
    const String endpoint = '/oidc/me';
    const String accessToken = 'access_token';

    final interceptor = nock(logtoOrigin).post(endpoint)
      ..headers({'authorization': 'Bearer $accessToken'})
      ..reply(200, mockUserInfoResponse,
          headers: {'Content-Type': 'application/json'});

    var result = await logto_core.fetchUserInfo(
      httpClient: http.Client(),
      userInfoEndpoint: '$logtoOrigin$endpoint',
      accessToken: accessToken,
    );

    expect(interceptor.isDone, true);
    expect(result.sub, mockUserInfoResponse['sub']);
    expect(result.name, mockUserInfoResponse['name']);
    expect(result.username, mockUserInfoResponse['username']);
    expect(result.picture, mockUserInfoResponse['picture']);
    expect(result.customData, mockUserInfoResponse['custom_data']);
    expect(result.email, mockUserInfoResponse['email']);
    expect(result.emailVerified, mockUserInfoResponse['email_verified']);
    expect(result.phoneNumber, mockUserInfoResponse['phone_number']);
    expect(result.phoneNumberVerified,
        mockUserInfoResponse['phone_number_verified']);
    expect(result.identities, mockUserInfoResponse['identities']);
  });
}
