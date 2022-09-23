import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LogtoWebview extends StatefulWidget {
  final Uri url;
  final String? callbackUri;
  final Future<void> Function(String callbackUri)? callbackHandler;

  const LogtoWebview(
      {Key? key, required this.url, this.callbackUri, this.callbackHandler})
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
    if (widget.callbackUri != null &&
        request.url.startsWith(widget.callbackUri!)) {
      widget.callbackHandler?.call(request.url);
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
