import 'package:json_annotation/json_annotation.dart';

part 'oidc_provider_config.g.dart';

@JsonSerializable()
class OidcProviderConfig {
  @JsonKey(
      name: 'authorization_endpoint', required: true, disallowNullValue: true)
  final String authorizationEndpoint;
  @JsonKey(name: 'token_endpoint', required: true, disallowNullValue: true)
  final String tokenEndpoint;
  @JsonKey(
      name: 'end_session_endpoint', required: true, disallowNullValue: true)
  final String endSessionEndpoint;
  @JsonKey(name: 'revocation_endpoint', required: true, disallowNullValue: true)
  final String revocationEndpoint;
  @JsonKey(name: 'jwks_uri', required: true, disallowNullValue: true)
  final String jwksUri;
  @JsonKey(name: 'issuer', required: true, disallowNullValue: true)
  final String issuer;

  OidcProviderConfig(this.authorizationEndpoint, this.endSessionEndpoint,
      this.issuer, this.jwksUri, this.revocationEndpoint, this.tokenEndpoint);

  factory OidcProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$OidcProviderConfigFromJson(json);

  Map<String, dynamic> toJson() => _$OidcProviderConfigToJson(this);
}
