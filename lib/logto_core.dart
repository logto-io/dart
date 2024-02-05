import 'package:http/http.dart' as http;

import '/src/exceptions/logto_auth_exceptions.dart';
import '/src/interfaces/logto_interfaces.dart';
import '/src/utilities/constants.dart';
import '/src/utilities/http_utils.dart';
import '/src/utilities/utils.dart';

export '/src/interfaces/logto_interfaces.dart';
export '/src/utilities/constants.dart';
export '/src/exceptions/logto_auth_exceptions.dart';

const String _codeChallengeMethod = 'S256';
const String _responseType = 'code';
const String _prompt = 'consent';
const String _requestContentType = 'application/x-www-form-urlencoded';

/**
 * logto_core.dart
 * 
 * This file is part of the Logto SDK. 
 * It contains the core functionalities of the OIDC authentication flow.
 * Use this module if you want to build your own custom SDK.
 */

/**
 * By default Logto use sign-in as the landing page for the user.
 * Use this enum to specify the interaction mode.
 * 
 * - signIn: The user will be redirected to the sign-in page.
 * - signUp: The user will be redirected to the sign-up page.
 */
enum InteractionMode { signIn, signUp }

extension InteractionModeExtension on InteractionMode {
  String get value {
    switch (this) {
      case InteractionMode.signIn:
        return 'signIn';
      case InteractionMode.signUp:
        return 'signUp';
      default:
        throw Exception("Invalid value");
    }
  }
}

/**
 * Fetch the OIDC provider configuration.
 */
Future<OidcProviderConfig> fetchOidcConfig(
    http.Client httpClient, String endpoint) async {
  final response = await httpClient.get(Uri.parse(endpoint));

  var body = httpResponseHandler(response);

  return OidcProviderConfig.fromJson(body);
}

/**
 * Fetch token using the authorization code.
 */
Future<LogtoCodeTokenResponse> fetchTokenByAuthorizationCode(
    {required http.Client httpClient,
    required String tokenEndPoint,
    required String code,
    required String codeVerifier,
    required String clientId,
    required String redirectUri,
    String? resource}) async {
  Map<String, dynamic> payload = {
    'grant_type': authorizationCodeGrantType,
    'code': code,
    'code_verifier': codeVerifier,
    'client_id': clientId,
    'redirect_uri': redirectUri,
  };

  if (resource != null && resource.isNotEmpty) {
    payload.addAll({'resource': resource});
  }

  final response = await httpClient.post(Uri.parse(tokenEndPoint),
      headers: {'Content-Type': _requestContentType}, body: payload);

  var body = httpResponseHandler(response);

  return LogtoCodeTokenResponse.fromJson(body);
}

/**
 * Fetch token using the refresh token.
 */
Future<LogtoRefreshTokenResponse> fetchTokenByRefreshToken({
  required http.Client httpClient,
  required String tokenEndPoint,
  required String clientId,
  required String refreshToken,
  String? resource,
  String? organizationId,
  List<String>? scopes,
}) async {
  Map<String, dynamic> payload = {
    'grant_type': refreshTokenGrantType,
    'client_id': clientId,
    'refresh_token': refreshToken,
  };

  if (resource != null && resource.isNotEmpty) {
    payload.addAll({'resource': resource});
  }

  if (organizationId != null && organizationId.isNotEmpty) {
    payload.addAll({'organization_id': organizationId});
  }

  if (scopes != null && scopes.isNotEmpty) {
    payload.addAll({'scope': scopes.join(' ')});
  }

  final response = await httpClient.post(Uri.parse(tokenEndPoint),
      headers: {'Content-Type': _requestContentType}, body: payload);

  var body = httpResponseHandler(response);

  return LogtoRefreshTokenResponse.fromJson(body);
}

/**
 * Fetch user info using the access token.
 */
Future<LogtoUserInfoResponse> fetchUserInfo(
    {required http.Client httpClient,
    required String userInfoEndpoint,
    required String accessToken}) async {
  final response = await httpClient.post(Uri.parse(userInfoEndpoint),
      headers: {'Authorization': 'Bearer $accessToken'});

  var body = httpResponseHandler(response);

  return LogtoUserInfoResponse.fromJson(body);
}

/**
 * Revoke the token.
 */
Future<void> revoke({
  required http.Client httpClient,
  required String revocationEndpoint,
  required String clientId,
  required String token,
}) =>
    httpClient.post(Uri.parse(revocationEndpoint),
        headers: {'Content-Type': _requestContentType},
        body: {'client_id': clientId, 'token': token});

/**
 * Generate the sign-in URI (Authorization URI). 
 * This URI will be used to initiate the OIDC authentication flow.
 */
Uri generateSignInUri(
    {required String authorizationEndpoint,
    required clientId,
    required String redirectUri,
    required String codeChallenge,
    required String state,
    List<String>? scopes,
    List<String>? resources,
    InteractionMode? interactionMode,
    String prompt = _prompt}) {
  var signInUri = Uri.parse(authorizationEndpoint);

  Map<String, dynamic> queryParameters = {
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'code_challenge': codeChallenge,
    'code_challenge_method': _codeChallengeMethod,
    'state': state,
    'scope': withReservedScopes(scopes ?? []).join(' '),
    'response_type': _responseType,
    'prompt': prompt,
  };

  // Auto add organization resource if scopes contains organization scope
  if (scopes != null && scopes.contains(LogtoUserScope.organizations.value)) {
    resources ??= [];

    if (!resources.contains(LogtoReservedResource.organization.value)) {
      resources.add(LogtoReservedResource.organization.value);
    }
  }

  if (resources != null && resources.isNotEmpty) {
    queryParameters.addAll({'resource': resources});
  }

  if (interactionMode != null) {
    // need to align with the backend OIDC params name
    queryParameters.addAll({'interaction_mode': interactionMode.value});
  }

  return addQueryParameters(signInUri, queryParameters);
}

/**
 * Generate the sign-out URI (End Session URI). 
 */
Uri generateSignOutUri({
  required String endSessionEndpoint,
  required String clientId,
  Uri? postLogoutRedirectUri,
}) {
  var signOutUri = Uri.parse(endSessionEndpoint);

  return addQueryParameters(signOutUri, {
    'client_id': clientId,
    'post_logout_redirect_uri': postLogoutRedirectUri?.toString()
  });
}

/**
 * A utility function to verify and parse the code from the authorization callback URI.
 * 
 * - verify the callback URI
 * - verify the state
 * - error detection
 * - parse the code from the callback URI
 */
String verifyAndParseCodeFromCallbackUri(
    String callbackUri, String redirectUri, String state) {
  if (!callbackUri.startsWith(redirectUri)) {
    throw LogtoAuthException(
        LogtoAuthExceptions.callbackUriValidationError, 'invalid redirect uri');
  }

  var queryParams = Uri.parse(callbackUri).queryParameters;

  if (queryParams['error'] != null) {
    throw LogtoAuthException(LogtoAuthExceptions.callbackUriValidationError,
        queryParams['error']!, queryParams['error_description']);
  }

  if (queryParams['state'] == null) {
    throw LogtoAuthException(
        LogtoAuthExceptions.callbackUriValidationError, 'missing state');
  }

  if (queryParams['state'] != state) {
    throw LogtoAuthException(
        LogtoAuthExceptions.callbackUriValidationError, 'invalid state');
  }

  if (queryParams['code'] == null) {
    throw LogtoAuthException(
        LogtoAuthExceptions.callbackUriValidationError, 'missing code');
  }

  return queryParams['code']!;
}
