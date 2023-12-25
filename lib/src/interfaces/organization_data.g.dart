// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationData _$OrganizationDataFromJson(Map<String, dynamic> json) =>
    OrganizationData(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$OrganizationDataToJson(OrganizationData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };
