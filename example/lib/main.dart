import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logto_dart_sdk/logto_core.dart';

void main() {
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
  String content = 'Logto SDK Demo Home Page';
  var client = http.Client();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  void _init() async {
    LogtoCore.fetchOidcConfig(
            "https://logto.dev/oidc/.well-known/openid-configuration", client)
        .then((value) => {
              setState(() {
                content = value.toJson().toString();
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(64),
              child: Text(
                content,
              ),
            )
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
