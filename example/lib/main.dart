import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logto_dart_sdk/logto_dart_sdk.dart';

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

  final client = http.Client();
  final redirectUri = 'io.logto://callback';
  final config = const LogtoConfig(
      appId: 'xgSxW0MDpVqW2GDvCnlNb', endpoint: 'https://logto.dev');

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
      content = "";
      isAuthenticated = false;
    });
  }

  void _init() async {
    logtoClient = LogtoClient(config, client);
    render();
  }

  void signInCallback(String callbackUri) {
    render();
  }

  void signOutCallback() {
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
      onPressed: () {
        logtoClient.signIn(context, redirectUri, signInCallback);
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
        await logtoClient.signOut(context, redirectUri);
        signOutCallback();
      },
      child: const Text('Sign Out'),
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
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }
}
