import 'package:flutter_test/flutter_test.dart';
import 'package:logto_dart_sdk/logto_client.dart';
import 'package:logto_dart_sdk/logto_dart_sdk.dart';
import 'package:nock/nock.dart';

import 'mocks/mock_storage.dart';

void main() {
  setUpAll(() async {
    nock.init;
  });

  tearDownAll(() {
    nock.cleanAll();
  });

  test('Init Logto Instance', () {
    const String appId = 'foo';
    const String endpoint = 'foo@siverhand.io';

    const config = LogtoConfig(appId: 'foo', endpoint: 'foo@siverhand.io');

    final logto = LogtoClient(
      config: config,
      storageProvider: MockStorageStrategy(),
    );

    expect(logto.config.appId, appId);
    expect(logto.config.endpoint, endpoint);
  });
}
