import '/src/utilities/utils.dart';

class Core {
  static const String codeChallengeMethod = 'S256';
  static const String responseType = 'code';
  static const String prompt = 'consent';

  static Uri generateSignInUri(
      {required String authorizationEndpoint,
      required clientId,
      required Uri redirectUri,
      required String codeChallenge,
      required String state,
      List<String> scopes = const [],
      List<String>? resources,
      String prompt = Core.prompt}) {
    var signInUri = Uri.parse(authorizationEndpoint);

    Map<String, dynamic> queryParameters = {
      'client_id': clientId,
      'redirect_uri': redirectUri.toString(),
      'code_challenge': codeChallenge,
      'code_challenge_method': Core.codeChallengeMethod,
      'state': state,
      'scope': withReservedScopes(scopes).join(' '),
      'response_type': Core.responseType,
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
