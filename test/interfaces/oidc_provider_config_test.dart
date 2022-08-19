import 'package:flutter_test/flutter_test.dart';

import 'package:logto_dart_sdk/src/interfaces/oidc_provider_config.dart';

void main() {
  test('Construct OIDC config from json', () {
    const response = {'test': 'foo'};
    expect(() {
      OidcProviderConfig.fromJson(response);
    }, throwsException);
  });
}
