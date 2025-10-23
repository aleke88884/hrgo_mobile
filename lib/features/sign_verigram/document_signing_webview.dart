import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocumentSigningWebView extends StatefulWidget {
  final String url;

  const DocumentSigningWebView({super.key, required this.url});

  @override
  State<DocumentSigningWebView> createState() => _DocumentSigningWebViewState();
}

class _DocumentSigningWebViewState extends State<DocumentSigningWebView> {
  bool _isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            if (request.url.contains('success') ||
                request.url.contains('complete')) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Подписание документа',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
