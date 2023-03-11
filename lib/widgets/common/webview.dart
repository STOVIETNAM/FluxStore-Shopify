import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as flutter;

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../html/index.dart';
import 'webview_inapp.dart';

class WebView extends StatefulWidget {
  final String? url;
  final String? title;
  final AppBar? appBar;
  final bool enableForward;

  const WebView(
      {Key? key,
      this.title,
      required this.url,
      this.appBar,
      this.enableForward = false})
      : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  bool isLoading = true;
  String html = '';
  late flutter.WebViewController _controller;

  @override
  void initState() {
    if (isMacOS) {
      httpGet(widget.url.toString().toUri()!).then((response) {
        setState(() {
          html = response.body;
        });
      });
    }

    if (isAndroid) flutter.WebView.platform = flutter.SurfaceAndroidWebView();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isMacOS || isWindow) {
      return Scaffold(
        appBar: widget.appBar ??
            AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              elevation: 0.0,
              title: Text(
                widget.title ?? '',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
        body: SingleChildScrollView(
          child: HtmlWidget(html),
        ),
      );
    }

    /// is Mobile or Web
    if (!kIsWeb && (kAdvanceConfig['inAppWebView'] ?? false)) {
      return WebViewInApp(url: widget.url!, title: widget.title);
    }

    return Scaffold(
      appBar: widget.appBar ??
          AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0.0,
            title: Text(
              widget.title ?? '',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            leadingWidth: 150,
            leading: Builder(builder: (buildContext) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () async {
                      var value = await _controller.canGoBack();
                      if (value) {
                        await _controller.goBack();
                      } else if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      } else {
                        Tools.showSnackBar(Scaffold.of(buildContext),
                            S.of(context).noBackHistoryItem);
                      }
                    },
                  ),
                  if (widget.enableForward)
                    IconButton(
                      onPressed: () async {
                        if (await _controller.canGoForward()) {
                          await _controller.goForward();
                        } else {
                          Tools.showSnackBar(Scaffold.of(buildContext),
                              S.of(context).noForwardHistoryItem);
                        }
                      },
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                ],
              );
            }),
          ),
      body: Builder(builder: (BuildContext context) {
        return flutter.WebView(
          initialUrl: widget.url!,
          javascriptMode: flutter.JavascriptMode.unrestricted,
          onWebViewCreated: (webViewController) {
            _controller = webViewController;
          },
          gestureNavigationEnabled: true,
        );
      }),
    );
  }
}
