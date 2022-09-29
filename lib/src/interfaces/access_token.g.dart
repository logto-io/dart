// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessToken _$AccessTokenFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['token', 'scope', 'expiresAt'],
    disallowNullValues: const ['token', 'scope', 'expiresAt'],
  );
  return AccessToken(
    token: json['token'] as String,
    scope: json['scope'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}

Map<String, dynamic> _$AccessTokenToJson(AccessToken instance) =>
    <String, dynamic>{
      'token': instance.token,
      'scope': instance.scope,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
