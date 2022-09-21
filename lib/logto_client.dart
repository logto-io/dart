import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';

import '/logto_core.dart' as logto_core;
import '/src/exceptions/logto_auth_exceptions.dart';
import '/src/interfaces/logto_interfaces.dart';
import '/src/utilities/constants.dart';
import '/src/utilities/id_token.dart';
import '/src/utilities/pkce.dart';
import '/src/utilities/token_storage.dart';
import '/src/utilities/utils.dart' as utils;
import '/src/utilities/webview_provider.dart';
import '/src/utilities/logto_storage_strategy.dart';

export '/src/interfaces/logto_config.dart';

// Logto SDK
class LogtoClient {
  final LogtoConfig config;
  final http.Client _httpClient;

  late PKCE _pkce;
  late String _state;

  static late TokenStorage _tokenStorage;

  OidcProviderConfig? _oidcConfig;

  LogtoClient(this.config, this._httpClient,
      [LogtoStorageStrategy? storageProvider]) {
    _tokenStorage = TokenStorage(storageProvider);
  }

  Future<bool> get isAuthenticated async {
    return await _tokenStorage.idToken != null;
  }

  Future<String?> get idToken async {
    var token = await _tokenStorage.idToken;
    return token?.serialization;
  }

  Future<OpenIdClaims?> get idTokenClaims async {
    var token = await _tokenStorage.idToken;
    return token?.claims;
  }

  Future<OidcProviderConfig> _getOidcConfig() async {
    if (_oidcConfig != null) {
      return _oidcConfig!;
    }

    var discoveryUri = utils.appendUriPath(config.endpoint, discoveryPath);
    _oidcConfig = await logto_core.fetchOidcConfig(_httpClient, discoveryUri);

    return _oidcConfig!;
  }

  bool _loading = false;

  Future<void> signIn(
    BuildContext context,
    String redirectUri,
    void Function() signInCallback,
  ) async {
    if (_loading) return;
    _loading = true;
    _pkce = PKCE.generate();
    _state = utils.generateRandomString();
    _tokenStorage.setIdToken(null);

    var oidcConfig = await _getOidcConfig();

    var signInUri = logto_core.generateSignInUri(
      authorizationEndpoint: oidcConfig.authorizationEndpoint,
      clientId: config.appId,
      redirectUri: redirectUri,
      codeChallenge: _pkce.codeChallenge,
      state: _state,
      resources: config.resources,
      scopes: config.scopes,
    );

    // ignore: use_build_context_synchronously
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogtoWebview(
          url: signInUri,
          signInCallbackUri: redirectUri,
          signInCallbackHandler: (String callbackUri) async {
            await _handleSignInCallback(callbackUri, redirectUri);
            signInCallback();
          },
        ),
      ),
    );
    _loading = false;
  }

  Future _handleSignInCallback(String callbackUri, String redirectUri) async {
    var code = logto_core.verifyAndParseCodeFromCallbackUri(
        callbackUri, redirectUri, _state);

    var oidcConfig = await _getOidcConfig();

    var tokenResponse = await logto_core.fetchTokenByAuthorizationCode(
        httpClient: _httpClient,
        tokenEndPoint: oidcConfig.tokenEndpoint,
        code: code,
        codeVerifier: _pkce.codeVerifier,
        clientId: config.appId,
        redirectUri: redirectUri);

    var idToken = IdToken.unverified(tokenResponse.idToken);

    var keyStore = JsonWebKeyStore()
      ..addKeySetUrl(Uri.parse(oidcConfig.jwksUri));

    if (!await idToken.verify(keyStore)) {
      throw LogtoAuthException(
          LogtoAuthExceptions.idTokenValidationError, 'invalid jws signature');
    }

    var violations = idToken.claims
        .validate(issuer: Uri.parse(oidcConfig.issuer), clientId: config.appId);

    if (violations.isNotEmpty) {
      throw LogtoAuthException(
          LogtoAuthExceptions.idTokenValidationError, '$violations');
    }

    await _tokenStorage.save(
        idToken: idToken,
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken);
  }
}
