import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../widgets/common/index.dart';
import '../common/app_bar_mixin.dart';

class WebViewScreen extends StatefulWidget {
  final String? title;
  final String? url;

  const WebViewScreen({
    this.title,
    required this.url,
  });

  @override
  _StateWebViewScreen createState() => _StateWebViewScreen();
}

class _StateWebViewScreen extends State<WebViewScreen> with AppBarMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar(RouteList.page) ? appBarWidget : null,
      body: WebView(
        url: widget.url,
        title: widget.title,
        enableForward: true,
      ),
    );
  }
}
