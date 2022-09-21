import 'id_token.dart';
import 'logto_storage_strategy.dart';

class _TokenStorageKeys {
  static const accessTokenKey = 'logto_access_token';
  static const refreshTokenKey = 'logto_refresh_token';
  static const idTokenKey = 'logto_id_token';
}

class TokenStorage {
  IdToken? _idToken;
  String? _accessToken;
  String? _refreshToken;

  late final LogtoStorageStrategy _storage;

  static TokenStorage? loaded;

  TokenStorage(
    LogtoStorageStrategy? storageStrategy,
  ) {
    _storage = storageStrategy ?? SecureStorageStrategy();
  }

  static IdToken? _decodeIdToken(String? encoded) {
    if (encoded == null) return null;
    return IdToken.unverified(encoded);
  }

  static String? _encodeIdToken(IdToken? token) {
    return token?.toCompactSerialization();
  }

  Future<IdToken?> get idToken async {
    if (_idToken != null) {
      return _idToken!;
    }

    var idTokenFromStorage =
        await _storage.read(key: _TokenStorageKeys.idTokenKey);
    _idToken = _decodeIdToken(idTokenFromStorage);

    return _idToken;
  }

  // TODO: convert the AccessToken storage to Map<resource, token>
  // Access token is requested and granted based on different resources
  // should be able to store and get the access token base on different resource
  Future<String?> get accessToken async {
    if (_accessToken != null) {
      return _accessToken;
    }

    _accessToken = await _storage.read(key: _TokenStorageKeys.accessTokenKey);

    return _accessToken;
  }

  Future<String?> get refreshToken async {
    if (_refreshToken != null) {
      return _refreshToken;
    }

    _refreshToken = await _storage.read(key: _TokenStorageKeys.refreshTokenKey);

    return _refreshToken;
  }

  Future<void> setIdToken(IdToken? idToken) async {
    _idToken = idToken;

    await _storage.write(
      key: _TokenStorageKeys.idTokenKey,
      value: _encodeIdToken(idToken),
    );
  }

  Future<void> setAccessToken(String? accessToken) async {
    _accessToken = accessToken;
    await _storage.write(
      key: _TokenStorageKeys.accessTokenKey,
      value: accessToken,
    );
  }

  Future<void> setRefreshToken(String? refreshToken) async {
    _refreshToken = refreshToken;

    await _storage.write(
      key: _TokenStorageKeys.refreshTokenKey,
      value: refreshToken,
    );
  }

  Future<void> save(
      {IdToken? idToken, String? accessToken, String? refreshToken}) async {
    await Future.wait([
      setAccessToken(accessToken),
      setIdToken(idToken),
      setRefreshToken(refreshToken),
    ]);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _idToken = null;
    await Future.wait<void>([
      _storage.delete(key: _TokenStorageKeys.accessTokenKey),
      _storage.delete(key: _TokenStorageKeys.refreshTokenKey),
      _storage.delete(key: _TokenStorageKeys.idTokenKey),
    ]);
  }
}
