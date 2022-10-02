import 'dart:convert';

import 'id_token.dart';
import 'logto_storage_strategy.dart';
import '/src/interfaces/access_token.dart';

class _TokenStorageKeys {
  static const accessTokenKey = 'logto_access_token';
  static const refreshTokenKey = 'logto_refresh_token';
  static const idTokenKey = 'logto_id_token';
}

class TokenStorage {
  IdToken? _idToken;
  Map<String, AccessToken>? _accessTokenMap;
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

  static String _encodeScopes(List<String>? scopes) {
    final List<String> scopeList = scopes ?? [];
    scopeList.sort();
    return scopeList.join(' ');
  }

  Future<IdToken?> get idToken async {
    if (_idToken != null) {
      return _idToken!;
    }

    final idTokenFromStorage =
        await _storage.read(key: _TokenStorageKeys.idTokenKey);
    _idToken = _decodeIdToken(idTokenFromStorage);

    return _idToken;
  }

  Future<void> setIdToken(IdToken? idToken) async {
    _idToken = idToken;

    await _storage.write(
      key: _TokenStorageKeys.idTokenKey,
      value: _encodeIdToken(idToken),
    );
  }

  static String _buildAccessTokenKey(String? resource,
          [List<String>? scopes]) =>
      "${_encodeScopes(scopes)}@${resource ?? ''}";

  Future<Map<String, AccessToken>?> _getAccessTokenMapFromStorage() async {
    final tokenMapStorage =
        await _storage.read(key: _TokenStorageKeys.accessTokenKey);

    if (tokenMapStorage != null) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(tokenMapStorage);

        return Map.fromEntries(jsonMap.keys
            .map((key) => MapEntry(key, AccessToken.fromJson(jsonMap[key]))));
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  Future<AccessToken?> getAccessToken(
      [String? resource, List<String>? scopes]) async {
    final key = _buildAccessTokenKey(resource, scopes);

    _accessTokenMap ??= await _getAccessTokenMapFromStorage();

    final accessToken = _accessTokenMap?[key];

    // remove the access token if expired and return null
    if (accessToken?.isExpired == true) {
      await _deleteAccessToken(key);
      return null;
    }

    return accessToken;
  }

  Future<void> _deleteAccessToken(String accessTokenKey) async {
    final Map<String, AccessToken> tempAccessTokenMap =
        Map.from(_accessTokenMap ?? {});

    final value = tempAccessTokenMap.remove(accessTokenKey);

    // Do not update the storage if target accessToken does not exist
    if (value == null) return;

    // clean up the storage if is empty
    if (tempAccessTokenMap.isEmpty) {
      await _storage.delete(key: _TokenStorageKeys.accessTokenKey);
      _accessTokenMap = null;
      return;
    }

    await _saveAccessTokenMapToStorage(tempAccessTokenMap);
    _accessTokenMap = tempAccessTokenMap;
  }

  Future<void> _saveAccessTokenMapToStorage(
      Map<String, AccessToken> accessTokenMap) async {
    final jsonMap = Map.fromEntries(accessTokenMap.keys
        .map((key) => MapEntry(key, accessTokenMap[key]?.toJson())));
    await _storage.write(
        key: _TokenStorageKeys.accessTokenKey, value: jsonEncode(jsonMap));
  }

  Future<void> setAccessToken(String accessToken,
      {String? resource, List<String>? scopes, required int expiresIn}) async {
    final key = _buildAccessTokenKey(resource, scopes);

    final Map<String, AccessToken> newAccessTokenMap =
        Map.from(_accessTokenMap ?? {});

    newAccessTokenMap.addAll({
      key: AccessToken(
          token: accessToken,
          scope: _encodeScopes(scopes),

          /// convert the expireAt to standard utc time
          expiresAt: DateTime.now().add(Duration(seconds: expiresIn)).toUtc())
    });

    await _saveAccessTokenMapToStorage(newAccessTokenMap);

    _accessTokenMap = newAccessTokenMap;
  }

  Future<String?> get refreshToken async {
    if (_refreshToken != null) {
      return _refreshToken;
    }

    _refreshToken = await _storage.read(key: _TokenStorageKeys.refreshTokenKey);

    return _refreshToken;
  }

  Future<void> setRefreshToken(String? refreshToken) async {
    _refreshToken = refreshToken;

    await _storage.write(
      key: _TokenStorageKeys.refreshTokenKey,
      value: refreshToken,
    );
  }

  /// Initial token response saving
  ///
  /// * required IdToken
  /// * required AccessToken
  /// * required expiresIn
  /// * optional refreshToken
  /// * initial AccessToken id for OpenID use only does not have resource & scope
  Future<void> save({
    required IdToken idToken,
    required String accessToken,
    String? refreshToken,
    required int expiresIn,
  }) async {
    await Future.wait([
      setAccessToken(accessToken, expiresIn: expiresIn),
      setIdToken(idToken),
      setRefreshToken(refreshToken),
    ]);
  }

  Future<void> clear() async {
    _accessTokenMap = null;
    _refreshToken = null;
    _idToken = null;
    await Future.wait<void>([
      _storage.delete(key: _TokenStorageKeys.accessTokenKey),
      _storage.delete(key: _TokenStorageKeys.refreshTokenKey),
      _storage.delete(key: _TokenStorageKeys.idTokenKey),
    ]);
  }
}
