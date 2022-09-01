// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logto_user_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogtoUserInfoResponse _$LogtoUserInfoResponseFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['sub'],
    disallowNullValues: const ['sub'],
  );
  return LogtoUserInfoResponse(
    sub: json['sub'] as String,
    username: json['username'] as String?,
    name: json['name'] as String?,
    avatar: json['avatar'] as String?,
    roleNames: (json['role_names'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
  );
}

Map<String, dynamic> _$LogtoUserInfoResponseToJson(
        LogtoUserInfoResponse instance) =>
    <String, dynamic>{
      'sub': instance.sub,
      'username': instance.username,
      'name': instance.name,
      'avatar': instance.avatar,
      'role_names': instance.roleNames,
    };
