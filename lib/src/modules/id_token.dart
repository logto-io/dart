import 'package:jose/jose.dart';
// ignore: implementation_imports
import 'package:jose/src/util.dart';

abstract class UserInfo implements JsonObject {
  /// Subject (the user ID) of this token.
  String get subject => this['sub'];

  /// Full name of the user.
  String? get name => this['name'];

  /// Username of the user.
  String? get username => this['username'];

  /// URL of the user's profile picture.
  String? get avatar => this['avatar'];

  /// Email address of the user.
  String? get email => this['email'];

  /// Phone number of the user.
  String? get phone => this['phone'];

  /// Whether the user's email address has been verified.
  String? get emailVerified => this['email_verified'];

  /// Whether the user's phone number has been verified.
  String? get phoneVerified => this['phone_verified'];

  /// Roles that the user has for API resources.
  List<String>? get roles => this['roles'];

  /// Organization IDs that the user has membership in.
  List<String>? get organizations => this['organizations'];

  /// All organization roles that the user has. The format is `{organizationId}:{roleName}`.
  List<String>? get organizationRoles => this['organization_roles'];

  factory UserInfo.fromJson(Map<String, dynamic> json) = _UserInfoImpl.fromJson;
}

class _UserInfoImpl extends JsonObject with UserInfo {
  _UserInfoImpl.fromJson(Map<String, dynamic> super.json) : super.from();
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
  OpenIdClaims.fromJson(Map<String, dynamic> super.json) : super.fromJson();
}

class IdToken extends JsonWebToken {
  String serialization;

  IdToken.unverified(this.serialization) : super.unverified(serialization);

  @override
  OpenIdClaims get claims => OpenIdClaims.fromJson(super.claims.toJson());
}
