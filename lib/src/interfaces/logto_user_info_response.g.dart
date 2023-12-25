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
    LogtoUserInfoResponse instance) {
  final val = <String, dynamic>{
    'sub': instance.sub,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('username', instance.username);
  writeNotNull('name', instance.name);
  writeNotNull('picture', instance.picture);
  writeNotNull('email', instance.email);
  writeNotNull('email_verified', instance.emailVerified);
  writeNotNull('phone_number', instance.phoneNumber);
  writeNotNull('phone_number_verified', instance.phoneNumberVerified);
  writeNotNull('custom_data', instance.customData);
  writeNotNull('identities', instance.identities);
  writeNotNull('organizations', instance.organizations);
  writeNotNull('organization_roles', instance.organizationRoles);
  writeNotNull('organization_data', instance.organizationData);
  return val;
}
