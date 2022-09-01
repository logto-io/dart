import 'package:json_annotation/json_annotation.dart';

part 'logto_code_token_response.g.dart';

@JsonSerializable()
class LogtoCodeTokenResponse {
  @JsonKey(name: 'access_token', required: true, disallowNullValue: true)
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'id_token', required: true, disallowNullValue: true)
  final String idToken;
  @JsonKey(name: 'scope', required: true, disallowNullValue: true)
  final String scope;
  @JsonKey(name: 'expires_in', required: true, disallowNullValue: true)
  final int expiresIn;

  LogtoCodeTokenResponse({
    required this.accessToken,
    required this.idToken,
    required this.scope,
    required this.expiresIn,
    this.refreshToken,
  });

  factory LogtoCodeTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$LogtoCodeTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LogtoCodeTokenResponseToJson(this);
}
