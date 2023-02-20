import 'package:jose/jose.dart';
// ignore: implementation_imports
import 'package:jose/src/util.dart';

abstract class UserInfo implements JsonObject {
  String get subject => this['sub'];
  String? get name => this['name'];
  String? get username => this['username'];
  String? get avatar => this['avatar'];

  factory UserInfo.fromJson(Map<String, dynamic> json) = _UserInfoImpl.fromJson;
}

class _UserInfoImpl extends JsonObject with UserInfo {
  _UserInfoImpl.fromJson(Map<String, dynamic> json) : super.from(json);
}

class OpenIdClaims extends JsonWebTokenClaims with UserInfo {
  @override
  Uri get issuer => super.issuer!;

  @override
  List<String> get audience => super.audience!;

  @override
  DateTime get expiry => super.expiry!;

  @override
  DateTime get issuedAt => super.issuedAt!;

  @override
  OpenIdClaims.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class IdToken extends JsonWebToken {
  String serialization;

  IdToken.unverified(this.serialization) : super.unverified(serialization);

  @override
  OpenIdClaims get claims => OpenIdClaims.fromJson(super.claims.toJson());
}
