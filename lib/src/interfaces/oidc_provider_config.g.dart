// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oidc_provider_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OidcProviderConfig _$OidcProviderConfigFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'authorization_endpoint',
      'token_endpoint',
      'end_session_endpoint',
      'revocation_endpoint',
      'jwks_uri',
      'issuer'
    ],
    disallowNullValues: const [
      'authorization_endpoint',
      'token_endpoint',
      'end_session_endpoint',
      'revocation_endpoint',
      'jwks_uri',
      'issuer'
    ],
  );
  return OidcProviderConfig(
    json['authorization_endpoint'] as String,
    json['end_session_endpoint'] as String,
    json['issuer'] as String,
    json['jwks_uri'] as String,
    json['revocation_endpoint'] as String,
    json['token_endpoint'] as String,
  );
}

Map<String, dynamic> _$OidcProviderConfigToJson(OidcProviderConfig instance) =>
    <String, dynamic>{
      'authorization_endpoint': instance.authorizationEndpoint,
      'token_endpoint': instance.tokenEndpoint,
      'end_session_endpoint': instance.endSessionEndpoint,
      'revocation_endpoint': instance.revocationEndpoint,
      'jwks_uri': instance.jwksUri,
      'issuer': instance.issuer,
    };
