import 'package:http/http.dart' as http;
import 'package:logto_dart_sdk/src/interfaces/logto_user_info_response.dart';

import '/src/exceptions/logto_auth_exceptions.dart';
import '/src/interfaces/logto_interfaces.dart';
import '/src/utilities/constants.dart';
import '/src/utilities/http_utils.dart';
import '/src/utilities/utils.dart';

const String _codeChallengeMethod = 'S256';
const String _responseType = 'code';
const String _prompt = 'consent';
const String _requestContentType = 'application/x-www-form-urlencoded';

Future<OidcProviderConfig> fetchOidcConfig(
    http.Client httpClient, String endpoint) async {
  final response = await httpClient.get(Uri.parse(endpoint));

  var body = httpResponseHandler(response);

  return OidcProviderConfig.fromJson(body);
}

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

Future<LogtoRefreshTokenResponse> fetchTokenByRefreshToken({
  required http.Client httpClient,
  required String tokenEndPoint,
  required String clientId,
  required String refreshToken,
  String? resource,
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

  if (scopes != null && scopes.isNotEmpty) {
    payload.addAll({'scope': scopes.join(' ')});
  }

  final response = await httpClient.post(Uri.parse(tokenEndPoint),
      headers: {'Content-Type': _requestContentType}, body: payload);

  var body = httpResponseHandler(response);

  return LogtoRefreshTokenResponse.fromJson(body);
}

Future<LogtoUserInfoResponse> fetchUserInfo(
    {required http.Client httpClient,
    required String userInfoEndpoint,
    required String accessToken}) async {
  final response = await httpClient.post(Uri.parse(userInfoEndpoint),
      headers: {'Authorization': 'Bearer $accessToken'});

  var body = httpResponseHandler(response);

  return LogtoUserInfoResponse.fromJson(body);
}

Future<void> revoke({
  required http.Client httpClient,
  required String revocationEndpoint,
  required String clientId,
  required String token,
}) =>
    httpClient.post(Uri.parse(revocationEndpoint),
        headers: {'Content-Type': _requestContentType},
        body: {'client_id': clientId, 'token': token});

Uri generateSignInUri(
    {required String authorizationEndpoint,
    required clientId,
    required String redirectUri,
    required String codeChallenge,
    required String state,
    List<String>? scopes,
    List<String>? resources,
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

  if (resources != null && resources.isNotEmpty) {
    queryParameters.addAll({'resources': resources});
  }

  return addQueryParameters(signInUri, queryParameters);
}

Uri generateSignOutUri({
  required String endSessionEndpoint,
  required String idToken,
  Uri? postLogoutRedirectUri,
}) {
  var signOutUri = Uri.parse(endSessionEndpoint);

  return addQueryParameters(signOutUri, {
    'id_token_hint': idToken,
    'post_logout_redirect_uri': postLogoutRedirectUri.toString()
  });
}

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
