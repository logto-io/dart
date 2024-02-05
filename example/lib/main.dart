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
    return MaterialApp(
      title: 'Flutter SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const MyHomePage(title: 'Logto SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

ButtonStyle secondaryButtonStyle = TextButton.styleFrom(
  foregroundColor: Colors.black,
  padding: const EdgeInsets.all(16.0),
  textStyle: const TextStyle(fontSize: 20),
);

ButtonStyle primaryButtonStyle = TextButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: Colors.deepPurpleAccent,
  padding: const EdgeInsets.all(16.0),
  textStyle: const TextStyle(fontSize: 20),
);

class _MyHomePageState extends State<MyHomePage> {
  static String welcome = 'Logto SDK Demo Home Page';
  String? content;
  bool isAuthenticated = false;

  final redirectUri = 'io.logto://callback';

  final config = LogtoConfig(
      appId: 'oOeT50aNvY7QbLci6XJZt',
      endpoint: 'http://localhost:3001/',
      // resources: ['<your api resources>'], // Uncomment this line to request resource scopes
      scopes: [
        LogtoUserScope.phone.value,
        LogtoUserScope.email.value,
        // LogtoUserScope.organizations.value, // Uncomment this line to request organization scope
        // Add additional resource scopes here
      ]);

  late LogtoClient logtoClient;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void render() async {
    if (await logtoClient.isAuthenticated) {
      var claims = await logtoClient.idTokenClaims;
      setState(() {
        content = claims!.toJson().toString().replaceAll(',', ',\n');
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

  Future<void> _showMyDialog(String title, String content) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              style: secondaryButtonStyle,
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget signInButton = TextButton(
      style: primaryButtonStyle,
      onPressed: () async {
        await logtoClient.signIn(redirectUri);
        render();
      },
      child: const Text('Sign In'),
    );

    Widget signOutButton = TextButton(
      style: secondaryButtonStyle,
      onPressed: () async {
        await logtoClient.signOut();
        render();
      },
      child: const Text('Sign Out'),
    );

    Widget getUserInfoButton = TextButton(
      style: secondaryButtonStyle,
      onPressed: () async {
        var userInfo = await logtoClient.getUserInfo();
        _showMyDialog(
            'User Info', userInfo.toJson().toString().replaceAll(',', ',\n'));
      },
      child: const Text('Get User Info'),
    );

    Widget getOrganizationTokenButton = TextButton(
      style: secondaryButtonStyle,
      onPressed: () async {
        var token = await logtoClient.getOrganizationToken('cikmgibbmtvv');
        _showMyDialog('Organization Token', token!.toJson().toString());
      },
      child: const Text('Get Organization Token'),
    );

    Widget getResourceTokenButton = TextButton(
      style: secondaryButtonStyle,
      onPressed: () async {
        var token = await logtoClient.getAccessToken(
            resource: 'http://localhost:3001/api/test');
        _showMyDialog('Resource Token', token!.toJson().toString());
      },
      child: const Text('Get Resource Token'),
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
            isAuthenticated == true ? signOutButton : signInButton,
            isAuthenticated == true
                ? getUserInfoButton
                : const SizedBox.shrink(),
            isAuthenticated == true &&
                    (config.scopes
                            ?.contains(LogtoUserScope.organizations.value) ??
                        false)
                ? getOrganizationTokenButton
                : const SizedBox.shrink(),
            isAuthenticated == true && config.resources != null
                ? getResourceTokenButton
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
