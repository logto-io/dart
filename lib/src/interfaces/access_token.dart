import 'package:json_annotation/json_annotation.dart';

part 'access_token.g.dart';

@JsonSerializable()
class AccessToken {
  @JsonKey(name: 'token', required: true, disallowNullValue: true)
  final String token;
  @JsonKey(name: 'scope', required: true, disallowNullValue: true)
  final String scope;
  @JsonKey(name: 'expiresAt', required: true, disallowNullValue: true)
  final DateTime expiresAt;

  AccessToken({
    required this.token,
    required this.scope,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().toUtc().compareTo(expiresAt) > 0;

  factory AccessToken.fromJson(Map<String, dynamic> json) =>
      _$AccessTokenFromJson(json);

  Map<String, dynamic> toJson() => _$AccessTokenToJson(this);
}
