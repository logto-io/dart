import 'id_token.dart';

class TokenStorage {
  IdToken? idToken;
  String? accessToken;
  String? refreshToken;

  TokenStorage({this.idToken, this.accessToken, this.refreshToken});
}
