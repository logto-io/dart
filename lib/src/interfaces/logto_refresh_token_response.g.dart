// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logto_refresh_token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogtoRefreshTokenResponse _$LogtoRefreshTokenResponseFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['access_token', 'scope', 'expires_in'],
    disallowNullValues: const ['access_token', 'scope', 'expires_in'],
  );
  return LogtoRefreshTokenResponse(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String?,
    idToken: json['id_token'] as String?,
    expiresIn: json['expires_in'] as int,
    scope: json['scope'] as String,
  );
}

Map<String, dynamic> _$LogtoRefreshTokenResponseToJson(
        LogtoRefreshTokenResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'id_token': instance.idToken,
      'scope': instance.scope,
      'expires_in': instance.expiresIn,
    };
