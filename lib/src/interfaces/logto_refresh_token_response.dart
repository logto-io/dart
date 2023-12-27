import 'package:json_annotation/json_annotation.dart';

part 'logto_refresh_token_response.g.dart';

@JsonSerializable()
class LogtoRefreshTokenResponse {
  @JsonKey(name: 'access_token', required: true, disallowNullValue: true)
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'id_token')
  final String? idToken;
  @JsonKey(name: 'scope', required: true, disallowNullValue: true)
  final String scope;
  @JsonKey(name: 'expires_in', required: true, disallowNullValue: true)
  final int expiresIn;

  LogtoRefreshTokenResponse(
      {required this.accessToken,
      this.refreshToken,
      this.idToken,
      required this.expiresIn,
      required this.scope});

  factory LogtoRefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$LogtoRefreshTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LogtoRefreshTokenResponseToJson(this);
}
