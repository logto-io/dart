import 'package:flutter_test/flutter_test.dart';
import 'package:logto_dart_sdk/src/utilities/id_token.dart';
import 'package:logto_dart_sdk/src/utilities/logto_storage_strategy.dart';
import 'package:logto_dart_sdk/src/utilities/token_storage.dart';

import '../mocks/mock_storage.dart';

class _TokenStorageKeys {
  static const accessTokenKey = 'logto_access_token';
  static const refreshTokenKey = 'logto_refresh_token';
  static const idTokenKey = 'logto_id_token';
}

void main() {
  group('token storage test', () {
    late TokenStorage sut;
    const refreshToken = 'refresh_token';
    const accessToken = 'access_token';
    final idToken = IdToken.unverified(
        'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkNza2w2SDRGR3NpLXE0QkVPT1BQOWJlbHNoRGFHZjd3RXViVU5KQllwQmsifQ.eyJzdWIiOiJzV0FWNG96MHhnN1giLCJuYW1lIjoiSnVsaWFuIEhhcnRsIiwicGljdHVyZSI6Imh0dHBzOi8vYXZhdGFycy5naXRodWJ1c2VyY29udGVudC5jb20vdS85MDc5OTU2Mz92PTQiLCJ1c2VybmFtZSI6bnVsbCwicm9sZV9uYW1lcyI6W10sImF0X2hhc2giOiI4Und3Y051UFlwcHRwWUx5MjctaEFBIiwiYXVkIjoieGdTeFcwTURwVnFXMkdEdkNubE5iIiwiZXhwIjoxNjYzNTEzNDU3LCJpYXQiOjE2NjM1MDk4NTcsImlzcyI6Imh0dHBzOi8vbG9ndG8uZGV2L29pZGMifQ.U3Yn3P7Vk32lpEXjNTV9NKT9PBqM1JT8sn8jdmu0MIHLhJtdUZUxGFuiPYRDDqw7EKIsmr23VXNeKELsw7Xd7mRBTWYPLGQKDOzorVyiLmdVLuxEQYTJSEsI2qs51GZyFqYgaQHczxmOaqYKnr83RGifoNkjgBXYdIozVmAy3V67ddnHfstv7TN-f2-AgQ90zoa00RF_5HbD60_Hhl8RdDz92Y_wJ3dD5PeUp33rGpP319txxdU1DYk44cpH5AxbICunigx5dqZMYnD3Xy1B4jY5BNI6WBNMnFeDbmEQmNg9CijVAvqRN9JBzOpIEXbiznz-tb0RLOngrU3XitvAfR7NsF9YHnqp8XQrQ9itF6sI6fgALDL4FLlAOM58tlHk5M95F4G28H6KvM27n1I5TtFlUzMx1C6mR721wLbAE3l6HZoSU9heWz1liCdk_yNswhJSkFRk9rH1daieeRC_AH_6w3ufBXZ_rTOA9ziuba7C0mizp4SGQxXu57CGO8P80rkUVl-A6Z9_2IQNLfK6khlandYIwNSmpdt4OQn7DZp5eI7yXm2IIpouE304q27rgXl3wpcfHDilxniIGqKs7O-zO6uFNfZljCpvP2ZJNxzuCxizJ3eyGOqDsrLVnIONqrjpiYk2TO1MAdpzZpwKwKm2BRH3fpkDaoplwCPmqDs');
    late LogtoStorageStrategy storageStrategy;

    setUp(() {
      storageStrategy = MockStorageStrategy();
      sut = TokenStorage(storageStrategy);
    });

    tearDown(() async {
      await sut.clear();
    });
    test('should set access token locally and persist it', () async {
      await sut.setAccessToken(accessToken);

      expect(await sut.accessToken, equals(accessToken));

      final persistedStorageAccessToken =
          await storageStrategy.read(key: _TokenStorageKeys.accessTokenKey);

      expect(persistedStorageAccessToken, accessToken);
    });

    test('should set refresh token locally and persist it', () async {
      await sut.setRefreshToken(refreshToken);

      expect(await sut.refreshToken, equals(refreshToken));

      final persistedStorageRefreshToken =
          await storageStrategy.read(key: _TokenStorageKeys.refreshTokenKey);

      expect(persistedStorageRefreshToken, refreshToken);
    });

    test('should set id token locally and persist it', () async {
      await sut.setIdToken(idToken);

      final persistedStorageIdToken =
          await storageStrategy.read(key: _TokenStorageKeys.idTokenKey);

      expect(persistedStorageIdToken, idToken.serialization);
    });

    test('save method should persist current state of token storage', () async {
      await sut.save(
          idToken: idToken,
          accessToken: accessToken,
          refreshToken: refreshToken);

      expect(await storageStrategy.read(key: _TokenStorageKeys.accessTokenKey),
          accessToken);
      expect(await storageStrategy.read(key: _TokenStorageKeys.refreshTokenKey),
          refreshToken);
      expect(await storageStrategy.read(key: _TokenStorageKeys.idTokenKey),
          idToken.serialization);
    });

    test('clear method should delete persisted state', () async {
      await sut.save(
          idToken: idToken,
          accessToken: accessToken,
          refreshToken: refreshToken);

      await sut.clear();

      expect(await storageStrategy.read(key: _TokenStorageKeys.accessTokenKey),
          null);
      expect(await storageStrategy.read(key: _TokenStorageKeys.refreshTokenKey),
          null);
      expect(
          await storageStrategy.read(key: _TokenStorageKeys.idTokenKey), null);
    });

    test('clear method should delete in memory state', () async {
      await sut.save();
      await sut.clear();

      expect(await sut.accessToken, null);
      expect(await sut.refreshToken, null);
      expect(await sut.idToken, null);
    });
  });
}
