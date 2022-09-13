import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LogtoWebview extends StatefulWidget {
  final Uri url;
  final String signInCallbackUri;
  final Future<void> Function(String callbackUri) signInCallbackHandler;

  const LogtoWebview(
      {Key? key,
      required this.url,
      required this.signInCallbackUri,
      required this.signInCallbackHandler})
      : super(key: key);

  @override
  State<LogtoWebview> createState() => _LogtoWebView();
}

class _LogtoWebView extends State<LogtoWebview> {
  WebViewController? webViewController;

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    super.initState();
  }

  NavigationDecision _interceptNavigation(NavigationRequest request) {
    if (request.url.startsWith(widget.signInCallbackUri)) {
      widget.signInCallbackHandler(request.url);
      Navigator.pop(context);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: widget.url.toString(),
        onWebViewCreated: (controller) => webViewController = controller,
        navigationDelegate: _interceptNavigation,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
