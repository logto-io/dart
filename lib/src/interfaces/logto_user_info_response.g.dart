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
    picture: json['picture'] as String?,
    email: json['email'] as String?,
    emailVerified: json['email_verified'] as bool?,
    phoneNumber: json['phone_number'] as String?,
    phoneNumberVerified: json['phone_number_verified'] as bool?,
    customData: json['custom_data'] as Map<String, dynamic>?,
    identities: json['identities'] as Map<String, dynamic>?,
    roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
    organizations: (json['organizations'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    organizationRoles: (json['organization_roles'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    organizationData: (json['organization_data'] as List<dynamic>?)
        ?.map((e) => OrganizationData.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$LogtoUserInfoResponseToJson(
        LogtoUserInfoResponse instance) =>
    <String, dynamic>{
      'sub': instance.sub,
      if (instance.username case final value?) 'username': value,
      if (instance.name case final value?) 'name': value,
      if (instance.picture case final value?) 'picture': value,
      if (instance.email case final value?) 'email': value,
      if (instance.emailVerified case final value?) 'email_verified': value,
      if (instance.phoneNumber case final value?) 'phone_number': value,
      if (instance.phoneNumberVerified case final value?)
        'phone_number_verified': value,
      if (instance.customData case final value?) 'custom_data': value,
      if (instance.identities case final value?) 'identities': value,
      if (instance.roles case final value?) 'roles': value,
      if (instance.organizations case final value?) 'organizations': value,
      if (instance.organizationRoles case final value?)
        'organization_roles': value,
      if (instance.organizationData case final value?)
        'organization_data': value,
    };
