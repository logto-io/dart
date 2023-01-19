import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';

import '/src/exceptions/logto_auth_exceptions.dart';
import '/src/interfaces/logto_interfaces.dart';
import '/src/modules/id_token.dart';
import '/src/modules/logto_storage_strategy.dart';
import '/src/modules/pkce.dart';
import '/src/modules/token_storage.dart';
import '/src/utilities/constants.dart';
import '/src/utilities/utils.dart' as utils;
import 'logto_core.dart' as logto_core;

export '/src/interfaces/logto_config.dart';

// Logto SDK
class LogtoClient {
  final LogtoConfig config;

  late PKCE _pkce;
  late String _state;

  static late TokenStorage _tokenStorage;

  /// Logto automatically enables refresh token's rotation
  ///
  /// Simultaneous access token request may be problematic
  /// Use a request cache map to avoid the race condition
  static final Map<String, Future<AccessToken?>> _accessTokenRequestCache = {};

  /// Custom [http.Client].
  ///
  /// Note that you will have to call `close()` yourself when passing a [http.Client] instance.
  late final http.Client? _httpClient;

  bool _loading = false;

  bool get loading => _loading;

  OidcProviderConfig? _oidcConfig;

  LogtoClient({
    required this.config,
    LogtoStorageStrategy? storageProvider,
    http.Client? httpClient,
  }) {
    _httpClient = httpClient;
    _tokenStorage = TokenStorage(storageProvider);
  }

  Future<bool> get isAuthenticated async {
    return await _tokenStorage.idToken != null;
  }

  Future<String?> get idToken async {
    final token = await _tokenStorage.idToken;
    return token?.serialization;
  }

  Future<OpenIdClaims?> get idTokenClaims async {
    final token = await _tokenStorage.idToken;
    return token?.claims;
  }

  Future<OidcProviderConfig> _getOidcConfig(http.Client httpClient) async {
    if (_oidcConfig != null) {
      return _oidcConfig!;
    }

    final discoveryUri = utils.appendUriPath(config.endpoint, discoveryPath);
    _oidcConfig = await logto_core.fetchOidcConfig(httpClient, discoveryUri);

    return _oidcConfig!;
  }

  Future<AccessToken?> getAccessToken({String? resource}) async {
    final accessToken = await _tokenStorage.getAccessToken(resource);

    if (accessToken != null) {
      return accessToken;
    }

    // If no valid access token is found in storage, use refresh token to claim a new one
    final cacheKey = TokenStorage.buildAccessTokenKey(resource);

    // Reuse the cached request if is exist
    if (_accessTokenRequestCache[cacheKey] != null) {
      return _accessTokenRequestCache[cacheKey];
    }

    // Create new token request and add it to cache
    final newTokenRequest = _getAccessTokenByRefreshToken(resource);
    _accessTokenRequestCache[cacheKey] = newTokenRequest;

    final token = await newTokenRequest;
    // Clear the cache after response
    _accessTokenRequestCache.remove(cacheKey);

    return token;
  }

  // RBAC are not supported currently, no resource specific scopes are needed
  Future<AccessToken?> _getAccessTokenByRefreshToken(String? resource) async {
    final refreshToken = await _tokenStorage.refreshToken;

    if (refreshToken == null) {
      throw LogtoAuthException(
          LogtoAuthExceptions.authenticationError, 'not_authenticated');
    }

    final httpClient = _httpClient ?? http.Client();

    try {
      final oidcConfig = await _getOidcConfig(httpClient);

      final response = await logto_core.fetchTokenByRefreshToken(
          httpClient: httpClient,
          tokenEndPoint: oidcConfig.tokenEndpoint,
          clientId: config.appId,
          refreshToken: refreshToken,
          resource: resource);

      final scopes = response.scope.split(' ');

      await _tokenStorage.setAccessToken(response.accessToken,
          expiresIn: response.expiresIn, resource: resource, scopes: scopes);

      // renew refresh token
      await _tokenStorage.setRefreshToken(response.refreshToken);

      // verify and store id_token if not null
      if (response.idToken != null) {
        final idToken = IdToken.unverified(response.idToken!);
        await _verifyIdToken(idToken, oidcConfig);
        await _tokenStorage.setIdToken(idToken);
      }

      return await _tokenStorage.getAccessToken(resource, scopes);
    } finally {
      if (_httpClient == null) httpClient.close();
    }
  }

  Future<void> _verifyIdToken(
      IdToken idToken, OidcProviderConfig oidcConfig) async {
    final keyStore = JsonWebKeyStore()
      ..addKeySetUrl(Uri.parse(oidcConfig.jwksUri));

    if (!await idToken.verify(keyStore)) {
      throw LogtoAuthException(
          LogtoAuthExceptions.idTokenValidationError, 'invalid jws signature');
    }

    final violations = idToken.claims
        .validate(issuer: Uri.parse(oidcConfig.issuer), clientId: config.appId);

    if (violations.isNotEmpty) {
      throw LogtoAuthException(
          LogtoAuthExceptions.idTokenValidationError, '$violations');
    }
  }

  Future<void> signIn(String redirectUri) async {
    if (_loading) {
      throw LogtoAuthException(
          LogtoAuthExceptions.isLoadingError, 'Already signing in...');
    }

    final httpClient = _httpClient ?? http.Client();

    try {
      _loading = true;
      _pkce = PKCE.generate();
      _state = utils.generateRandomString();
      _tokenStorage.setIdToken(null);
      final oidcConfig = await _getOidcConfig(httpClient);

      final signInUri = logto_core.generateSignInUri(
        authorizationEndpoint: oidcConfig.authorizationEndpoint,
        clientId: config.appId,
        redirectUri: redirectUri,
        codeChallenge: _pkce.codeChallenge,
        state: _state,
        resources: config.resources,
        scopes: config.scopes,
      );
      String? callbackUri;

      final redirectUriScheme = Uri.parse(redirectUri).scheme;
      callbackUri = await FlutterWebAuth.authenticate(
        url: signInUri.toString(),
        callbackUrlScheme: redirectUriScheme,
        preferEphemeral: true,
      );

      await _handleSignInCallback(callbackUri, redirectUri, httpClient);
    } finally {
      _loading = false;
      if (_httpClient == null) httpClient.close();
    }
  }

  Future _handleSignInCallback(
      String callbackUri, String redirectUri, http.Client httpClient) async {
    final code = logto_core.verifyAndParseCodeFromCallbackUri(
      callbackUri,
      redirectUri,
      _state,
    );

    final oidcConfig = await _getOidcConfig(httpClient);

    final tokenResponse = await logto_core.fetchTokenByAuthorizationCode(
      httpClient: httpClient,
      tokenEndPoint: oidcConfig.tokenEndpoint,
      code: code,
      codeVerifier: _pkce.codeVerifier,
      clientId: config.appId,
      redirectUri: redirectUri,
    );

    final idToken = IdToken.unverified(tokenResponse.idToken);

    await _verifyIdToken(idToken, oidcConfig);

    await _tokenStorage.save(
        idToken: idToken,
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        expiresIn: tokenResponse.expiresIn);
  }

  Future<void> signOut() async {
    // Throw error is authentication status not found
    final idToken = await _tokenStorage.idToken;

    final httpClient = _httpClient ?? http.Client();

    if (idToken == null) {
      throw LogtoAuthException(
          LogtoAuthExceptions.authenticationError, 'not authenticated');
    }

    try {
      final oidcConfig = await _getOidcConfig(httpClient);

      // Revoke refresh token if exist
      final refreshToken = await _tokenStorage.refreshToken;

      if (refreshToken != null) {
        try {
          await logto_core.revoke(
            httpClient: httpClient,
            revocationEndpoint: oidcConfig.authorizationEndpoint,
            clientId: config.appId,
            token: refreshToken,
          );
        } catch (e) {
          // Do Nothing silently revoke the token
        }
      }

      await _tokenStorage.clear();
    } finally {
      if (_httpClient == null) {
        httpClient.close();
      }
    }
  }
}
