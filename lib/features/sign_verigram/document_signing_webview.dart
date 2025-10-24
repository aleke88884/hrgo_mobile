import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DocumentSigningWebView extends StatefulWidget {
  final String url;

  const DocumentSigningWebView({super.key, required this.url});

  @override
  State<DocumentSigningWebView> createState() => _DocumentSigningWebViewState();
}

class _DocumentSigningWebViewState extends State<DocumentSigningWebView> {
  bool _isLoading = true;
  late InAppWebViewController _webViewController;

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
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
              if (url != null &&
                  (url.toString().contains('success') ||
                      url.toString().contains('complete'))) {
                Navigator.pop(context, true);
              }
            },
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
