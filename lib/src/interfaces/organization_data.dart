import 'package:json_annotation/json_annotation.dart';

part 'organization_data.g.dart';

@JsonSerializable()
class OrganizationData {
  final String id;
  final String name;
  final String? description;

  OrganizationData({required this.id, required this.name, this.description});

  factory OrganizationData.fromJson(Map<String, dynamic> json) =>
      _$OrganizationDataFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizationDataToJson(this);
}
