import 'package:flutter/material.dart';
import 'package:logto_dart_sdk/logto_client.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const MyHomePage(title: 'Logto SDK Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static String welcome = 'Logto SDK Demo Home Page';
  String? content;
  bool? isAuthenticated;

  final redirectUri = 'io.logto://callback';
  final config = const LogtoConfig(
      appId: '<your-app-id>',
      endpoint: 'http://localhost:3001',
      scopes: ['email', 'phone']);

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

  void _init() async {
    logtoClient = LogtoClient(
      config: config,
      httpClient: http.Client(),
    );
    render();
  }

  @override
  Widget build(BuildContext context) {
    Widget signInButton = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent,
        padding: const EdgeInsets.all(16.0),
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () async {
        await logtoClient.signIn(redirectUri);
        render();
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
