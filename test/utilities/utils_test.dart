import 'package:flutter_test/flutter_test.dart';

import 'package:logto_dart_sdk/src/utilities/utils.dart';
import 'package:logto_dart_sdk/src/utilities/constants.dart';

void main() {
  test('addQueryParameters', () {
    Uri url = Uri.parse('http://foo.dev?param1=test');
    Uri result = addQueryParameters(url, {"param2": 'foo'});

    expect(result.queryParameters['param1'], 'test');
    expect(result.queryParameters['param2'], 'foo');
  });

  test('removeQueryParameters', () {
    Uri url = Uri.parse('http://foo.dev?param1=test');
    Uri result = removeQueryParameters(url, ['param1']);

    expect(result.queryParameters['param1'], isNull);
  });

  test('withReservedScopes', () {
    var scopes = withReservedScopes(['profile']);
    expect(scopes.contains('profile'), true);

    for (var scope in reservedScopes) {
      expect(scopes.contains(scope), true);
    }
  });

  test('appendUriPath', () {
    const String url = 'http://foo.dev?param1=test';
    String result = appendUriPath(url, 'logto');
    expect(result, 'http://foo.dev/logto?param1=test');
  });
}
