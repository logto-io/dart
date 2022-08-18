import 'package:flutter_test/flutter_test.dart';

import 'package:logto_dart_sdk/interfaces/logto_config.dart';
import 'package:logto_dart_sdk/logto_client.dart';

void main() {
  test(' Init Logto Instance', () {
    const String appId = 'foo';
    const String endpoint = 'foo@siverhand.io';

    final config = LogtoConfig(appId: 'foo', endpoint: 'foo@siverhand.io');
    final logto = Logto(config);

    expect(logto.config.appId, appId);
    expect(logto.config.endpoint, endpoint);
  });
}
