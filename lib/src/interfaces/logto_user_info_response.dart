import 'package:json_annotation/json_annotation.dart';

part 'logto_user_info_response.g.dart';

@JsonSerializable(includeIfNull: false)
class LogtoUserInfoResponse {
  @JsonKey(name: 'sub', required: true, disallowNullValue: true)
  final String sub;
  @JsonKey(name: 'username')
  final String? username;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'picture')
  final String? picture;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'email_verified')
  final bool? emailVerified;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'phone_number_verified')
  final bool? phoneNumberVerified;
  @JsonKey(name: 'custom_data')
  final Map<String, dynamic>? customData;
  @JsonKey(name: 'identities')
  final Map<String, dynamic>? identities;

  LogtoUserInfoResponse({
    required this.sub,
    this.username,
    this.name,
    this.picture,
    this.email,
    this.emailVerified,
    this.phoneNumber,
    this.phoneNumberVerified,
    this.customData,
    this.identities,
  });

  factory LogtoUserInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$LogtoUserInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LogtoUserInfoResponseToJson(this);
}
