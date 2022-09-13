import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';

import 'package:logto_dart_sdk/logto_client.dart';

void main() {
  late http.Client httpClient;

  setUpAll(() {
    httpClient = http.Client();
    nock.init;
  });

  tearDownAll(() {
    nock.cleanAll();
    httpClient.close();
  });

  test('Init Logto Instance', () {
    const String appId = 'foo';
    const String endpoint = 'foo@siverhand.io';

    const config = LogtoConfig(appId: 'foo', endpoint: 'foo@siverhand.io');

    final logto = LogtoClient(config, httpClient);

    expect(logto.config.appId, appId);
    expect(logto.config.endpoint, endpoint);
  });
}
