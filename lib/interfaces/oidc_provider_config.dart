import 'package:jose/src/util.dart';

class OidcProviderConfig extends JsonObject {
  Uri get authorizationEndpoint => getTyped('authorization_endpoint')!;
  Uri get tokenEndpoint => getTyped('token_endpoint')!;
  Uri get issuer => getTyped('issuer')!;
  Uri get jwksUri => getTyped('jwks_uri')!;
  Uri get userinfoEndpoint => getTyped('userinfo_endpoint')!;
  Uri get revocationEndpoint => getTyped('revocation_endpoint')!;
  Uri get endSessionEndpoint => getTyped('end_session_endpoint')!;

  OidcProviderConfig.fromJson(Map<String, dynamic> json) : super.from(json);
}
