import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';

import 'package:example/main.dart';

import '../../test/mocks/oidc_config.dart';

void main() {
  setUpAll(nock.init);

  setUp(() {
    nock.cleanAll();
  });

  testWidgets('Logto Dart Demo App', (WidgetTester tester) async {
    final interceptor =
        nock("https://logto.dev").get("/oidc/.well-known/openid-configuration")
          ..reply(
            200,
            mockOidcConfigResponse,
          );

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    expect(find.text('Logto SDK Demo Home Page'), findsNWidgets(2));

    await tester.pump();
    expect(interceptor.isDone, true);
  });
}
