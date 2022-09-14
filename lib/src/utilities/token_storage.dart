import 'id_token.dart';

class TokenStorage {
  IdToken? idToken;
  String? accessToken;
  String? refreshToken;

  // TODO: Add persistant storage getter and setting
  TokenStorage({this.idToken, this.accessToken, this.refreshToken});
}
