import 'dart:convert';

import 'package:http/http.dart' as http;

import '/src/exceptions/http_request_exceptions.dart';
import '/src/interfaces/oidc_provider_config.dart';
import '/src/utilities/utils.dart';

class LogtoCore {
  static const String codeChallengeMethod = 'S256';
  static const String responseType = 'code';
  static const String prompt = 'consent';

  static Future<OidcProviderConfig> fetchOidcConfig(String endpoint) async {
    final response = await http.get(Uri.parse(endpoint));

    var body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpRequestException(statusCode: response.statusCode, body: body);
    }

    return OidcProviderConfig.fromJson(body);
  }

  static Uri generateSignInUri(
      {required String authorizationEndpoint,
      required clientId,
      required Uri redirectUri,
      required String codeChallenge,
      required String state,
      List<String> scopes = const [],
      List<String>? resources,
      String prompt = LogtoCore.prompt}) {
    var signInUri = Uri.parse(authorizationEndpoint);

    Map<String, dynamic> queryParameters = {
      'client_id': clientId,
      'redirect_uri': redirectUri.toString(),
      'code_challenge': codeChallenge,
      'code_challenge_method': LogtoCore.codeChallengeMethod,
      'state': state,
      'scope': withReservedScopes(scopes).join(' '),
      'response_type': LogtoCore.responseType,
      'prompt': prompt,
    };

    if (resources != null && resources.isNotEmpty) {
      queryParameters.addAll({'resources': resources});
    }

    return addQueryParameters(signInUri, queryParameters);
  }

  static Uri generateSignOutUri(
      {required String endSessionEndpoint,
      required String idToken,
      required Uri postLogoutRedirectUri}) {
    var signOutUri = Uri.parse(endSessionEndpoint);

    return addQueryParameters(signOutUri, {
      'id_token_hint': idToken,
      'post_logout_redirect_uri': postLogoutRedirectUri.toString()
    });
  }
}
