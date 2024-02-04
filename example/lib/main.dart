import 'package:flutter/material.dart';
import 'package:logto_dart_sdk/logto_client.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter SDK Demo',
      home: MyHomePage(title: 'Logto SDK Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static String welcome = 'Logto SDK Demo Home Page';
  String? content;
  bool? isAuthenticated;

  final redirectUri = 'io.logto://callback';

  final config = LogtoConfig(
      appId: 'oOeT50aNvY7QbLci6XJZt',
      endpoint: 'http://localhost:3001/',
      resources: [
        'http://localhost:3001/'
      ],
      scopes: [
        LogtoUserScope.phone.value,
        LogtoUserScope.email.value,
        LogtoUserScope.roles.value,
        LogtoUserScope.organizations.value,
        LogtoUserScope.organizationRoles.value,
        LogtoUserScope.identities.value,
        LogtoUserScope.customData.value,
      ]);

  late LogtoClient logtoClient;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<AccessToken?> getOrganizationAccessToken(String organizationId) async {
    var token =
        await logtoClient.getAccessToken(organizationId: organizationId);

    return token;
  }

  Future getIdTokenClaims() async {
    var claims = await logtoClient.idTokenClaims;
    return claims;
  }

  void render() async {
    if (await logtoClient.isAuthenticated) {
      var claims = await logtoClient.idTokenClaims;
      setState(() {
        content = claims!.toJson().toString();
        isAuthenticated = true;
      });
      return;
    }
    setState(() {
      content = '';
      isAuthenticated = false;
    });
  }

  void _init() {
    logtoClient = LogtoClient(
      config: config,
      httpClient: http.Client(),
    );
    render();
  }

  @override
  Widget build(BuildContext context) {
    Widget signInButton = TextButton(
      onPressed: () async {
        logtoClient.signIn(redirectUri);
      },
      child: const Text('Sign In'),
    );

    Widget signOutButton = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.all(16.0),
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () async {
        await logtoClient.signOut();
        render();
      },
      child: const Text('Sign Out'),
    );

    Widget getUserInfoButton = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.all(16.0),
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () async {
        var userInfo = await logtoClient.getUserInfo();
        setState(() {
          content = userInfo.toJson().toString();
        });
      },
      child: const Text('Get User Info'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SelectableText(welcome,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(64),
              child: SelectableText(
                content ?? '',
              ),
            ),
            isAuthenticated != null
                ? isAuthenticated == true
                    ? signOutButton
                    : signInButton
                : const SizedBox.shrink(),
            isAuthenticated != null
                ? isAuthenticated == true
                    ? getUserInfoButton
                    : const SizedBox.shrink()
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
