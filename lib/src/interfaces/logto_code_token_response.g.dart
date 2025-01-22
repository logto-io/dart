// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logto_code_token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogtoCodeTokenResponse _$LogtoCodeTokenResponseFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['access_token', 'id_token', 'scope', 'expires_in'],
    disallowNullValues: const [
      'access_token',
      'id_token',
      'scope',
      'expires_in'
    ],
  );
  return LogtoCodeTokenResponse(
    accessToken: json['access_token'] as String,
    idToken: json['id_token'] as String,
    scope: json['scope'] as String,
    expiresIn: (json['expires_in'] as num).toInt(),
    refreshToken: json['refresh_token'] as String?,
  );
}

Map<String, dynamic> _$LogtoCodeTokenResponseToJson(
        LogtoCodeTokenResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'id_token': instance.idToken,
      'scope': instance.scope,
      'expires_in': instance.expiresIn,
    };
